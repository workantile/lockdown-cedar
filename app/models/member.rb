require 'csv'

class Member < ActiveRecord::Base
	BILLING_PLANS = ['full','full - no work','affiliate','student','supporter', 'none']
  MEMBER_TYPES = ['current', 'former', 'courtesy key']
  AFFILIATE_FREE_DAY_PASSES = 4

  attr_accessible :first_name, :last_name, :email, :rfid, :member_type, :anniversary_date,
                  :billing_plan, :key_enabled, :task, :pay_simple_customer_id, :termination_date, :last_date_invoiced

  validates_presence_of :first_name, :last_name, :email, :member_type, :billing_plan
  validates_uniqueness_of :email
  validates_uniqueness_of :rfid, :allow_nil => true, :allow_blank => true

  validates :member_type, :inclusion => {:in => MEMBER_TYPES, :message => "%{value} is not a valid member type"}
  validates :billing_plan, :inclusion => {:in => BILLING_PLANS, :message => "%{value} is not a valid billing plan"}
  validates :key_enabled, :inclusion => {:in => [true, false]}

  after_initialize :set_default_anniversary_date
  before_save :check_member_type

  default_scope order("first_name ASC, last_name ASC")

  scope :current, where(:member_type => 'current')
  scope :full, where(:member_type => 'current', :billing_plan => 'full')
  scope :full_no_work, where(:member_type => 'current', :billing_plan => 'full - no work')
  scope :affiliate, where(:member_type => 'current', :billing_plan => 'affiliate')
  scope :student, where(:member_type => 'current', :billing_plan => 'student')
  scope :supporting, where(:member_type =>'current', :billing_plan => 'supporter')
  scope :former, where(:member_type => 'former')
  scope :courtesy_key, where(:member_type => 'courtesy key')
  scope :none, where("member_type <> 'current'")

  has_many :access_logs
  has_many :pending_updates, :dependent => :destroy
  
  def full_name
  	[first_name, last_name].join(' ')
  end

  def anniversary_date=(a_date)
  	if a_date.instance_of?(String)
  		self[:anniversary_date] = Date.strptime(a_date, "%m/%d/%Y") unless a_date.empty?
  	else
  		self[:anniversary_date] = a_date
  	end
  end

  def set_default_anniversary_date
  	self.anniversary_date ||= Date.today
  end
  
  def check_member_type
    # TODO: implement state machine
    if member_type == 'former'
      self.termination_date ||= Date.today
      self.billing_plan = 'none'
    end
  end

  def access_enabled?
    if key_enabled && (member_type == 'current' || member_type == 'courtesy key')
      true
    else
      false
    end
  end

  def billing_period_begins
    if anniversary_date
      anniversary_date.mday.ordinalize
    else
      ""
    end
  end

  def current_billing_period
    boundary_date = Date.new(Date.today.year, Date.today.month, self.anniversary_date.day)
    if Date.today < boundary_date
      boundary_date.prev_month..boundary_date.prev_day
    else
      boundary_date..boundary_date.next_month.prev_day
    end
  end

  def previous_billing_period
    current_billing_period.first.prev_month..current_billing_period.last.prev_month
  end

  def usage_this_month
    this_month = Date.new(Date.today.year, Date.today.month, 1)..Date.new(Date.today.year, Date.today.month, -1)
    self.access_logs.where(:access_date => this_month).count(:access_date, :distinct => true)
  end

  def usage_this_billing_period
    self.access_logs.where(:access_date => self.current_billing_period).count(:access_date, :distinct => true)
  end

  def usage_previous_billing_period
    self.access_logs.where(:access_date => self.previous_billing_period).count(:access_date, :distinct => true)
  end

  def billable_days_this_billing_period
    if self.usage_this_billing_period > AFFILIATE_FREE_DAY_PASSES
      self.usage_this_billing_period - AFFILIATE_FREE_DAY_PASSES
    else
      0
    end
  end

  def send_usage_email
    if billing_plan == "affiliate" && usage_email_sent != Date.today
      if self.usage_this_billing_period > AFFILIATE_FREE_DAY_PASSES
        MemberEmail.delay.billable_day_pass_use(self)
      else
        MemberEmail.delay.free_day_pass_use(self)
      end
      self.usage_email_sent = Date.today
      self.save
    end
  end

  def needs_invoicing?
    self.billing_plan == "affiliate" && 
    self.member_type == "current" &&
    self.usage_previous_billing_period > Member::AFFILIATE_FREE_DAY_PASSES &&
    (self.last_date_invoiced.nil? || self.last_date_invoiced < self.current_billing_period.first) ? true :false
  end

  def delay_update(attribute, value)
    run_at = self.current_billing_period.last + 1.day
    delay_obj = self.delay(:run_at => run_at).update_attributes(attribute => value)
    self.pending_updates.create(:description => "#{attribute.to_s} will be updated to #{value.to_s} on #{run_at.to_s}",
                               :delayed_job_id => delay_obj.id)
  end

  def destroy_pending_updates
    self.pending_updates.each { |pending_update| pending_update.destroy }
  end

  def self.grant_access?(rfid, door_address)
    member = find_by_rfid(rfid)
    member ||= find_by_rfid(rfid.downcase)
    door_controller = DoorController.find_by_address(door_address)
    if member && member.access_enabled? && door_controller
      AccessLog.create(:member => member,
                       :door_controller => door_controller,
                       :member_name => member.full_name,
                       :member_type => member.member_type,
                       :billing_plan => member.billing_plan,
                       :access_granted => true)
      true
    else
      false
    end
  end

  def self.lookup_type_plan(type, plan)
    case true
    when (type == 'all' && plan == 'all')
      Member.all
    when (type == 'all' && plan != 'all')
      Member.where("billing_plan = ?", plan)
    when (type != 'all' && plan == 'all')
      Member.where("member_type = ?", type)
    when (type != 'all' && plan != 'all')
      Member.where("member_type = ? and billing_plan = ?", type, plan)
    end
  end

  def self.export_to_csv(type, plan)
    members = self.lookup_type_plan(type, plan)
    headers = members.first.attributes.collect { |attribute| attribute[0] }
    CSV.generate do |csv|
      csv << headers
      members.each do |member|
        csv << headers.collect { |attribute| member[attribute]}
      end
    end
  end

  def self.members_to_invoice
    candidates = Member.where("member_type = 'current' and billing_plan = 'affiliate'")
    candidates.inject([]) do |members, member|
      members << member if member.needs_invoicing?
      members
    end
  end

end
