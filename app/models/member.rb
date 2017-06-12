require 'csv'

class Member < ActiveRecord::Base
	BILLING_PLANS = ['full','full - no work','affiliate','student','supporter', 'none']
  MEMBER_TYPES = ['current', 'former', 'courtesy key']
  AFFILIATE_FREE_DAY_PASSES = 4

  attr_accessible :first_name, :last_name, :email, :rfid, :member_type, :anniversary_date,
                  :billing_plan, :key_enabled, :task, :pay_simple_customer_id, :termination_date, :last_date_invoiced

  validates_presence_of :first_name, :last_name, :email, :member_type, :billing_plan
  validates_uniqueness_of :email, :case_sensitive => false
  validates_uniqueness_of :rfid, :allow_nil => true, :allow_blank => true, :case_sensitive => false

  validates :member_type, :inclusion => {:in => MEMBER_TYPES, :message => "%{value} is not a valid member type"}
  validates :billing_plan, :inclusion => {:in => BILLING_PLANS, :message => "%{value} is not a valid billing plan"}
  validates :key_enabled, :inclusion => {:in => [true, false]}

  after_initialize :set_default_anniversary_date
  before_save :check_member_type

  default_scope { order("first_name ASC, last_name ASC") }

  scope :current, -> { where(:member_type => 'current') }
  scope :full, -> { where(:member_type => 'current', :billing_plan => 'full') }
  scope :full_no_work, -> { where(:member_type => 'current', :billing_plan => 'full - no work') }
  scope :affiliate, -> { where(:member_type => 'current', :billing_plan => 'affiliate') }
  scope :student, -> { where(:member_type => 'current', :billing_plan => 'student') }
  scope :supporting, -> { where(:member_type =>'current', :billing_plan => 'supporter') }
  scope :former, -> { where(:member_type => 'former') }
  scope :courtesy_key, -> { where(:member_type => 'courtesy key') }
  # scope :none, -> { where("member_type <> 'current'") }

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
  	self.anniversary_date ||= Date.current
  end

  def check_member_type
    # TODO: implement state machine
    if member_type == 'former'
      self.termination_date ||= Date.current
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

  def first_of_month
    Date.new(Date.current.year, Date.current.month, 1)
  end

  def last_of_month
    Date.new(Date.current.year, Date.current.month, -1)
  end

  def this_month
    first_of_month..last_of_month
  end

  def last_month
    first_of_month.prev_month..last_of_month.prev_month
  end

  def usage_this_month
    self.access_logs.where(access_date: this_month).select(:access_date).distinct.count
  end

  def day_pass_usage_this_month
    self.access_logs.where(access_date: this_month, billable: true).select(:access_date).distinct.count
  end

  def usage_last_month
    self.access_logs.where(access_date: last_month).select(:access_date).distinct.count
  end

  def day_pass_usage_last_month
    self.access_logs.where(access_date: last_month, billable: true).select(:access_date).distinct.count
  end

  def non_billable_usage_last_month
    self.access_logs.where(access_date: last_month, billable: false).select(:access_date).distinct.count
  end

  def billable_usage_last_month
    result = day_pass_usage_last_month - AFFILIATE_FREE_DAY_PASSES
    result < 0 ? 0 : result
  end

  def non_billable_usage_this_month
    self.access_logs.where(access_date: this_month, billable: false).select(:access_date).distinct.count
  end

  def billable_usage_this_month
    result = day_pass_usage_this_month - AFFILIATE_FREE_DAY_PASSES
    result < 0 ? 0 : result
  end

  def send_usage_email?
    billing_plan == "affiliate" && usage_email_sent != Date.current
  end

  def needs_invoicing?
    self.billing_plan == "affiliate" &&
    self.member_type == "current" &&
    self.usage_last_month > Member::AFFILIATE_FREE_DAY_PASSES &&
    (self.last_date_invoiced.nil? || self.last_date_invoiced < self.first_of_month) ? true :false
  end

  def delay_update(attribute, value)
    run_at = self.last_of_month + 1.day
    delay_obj = self.delay(:run_at => run_at).update_attributes(attribute => value)
    self.pending_updates.create(:description => "#{attribute.to_s} will be updated to #{value.to_s} on #{run_at.to_s}",
                               :delayed_job_id => delay_obj.id)
  end

  def destroy_pending_updates
    self.pending_updates.each { |pending_update| pending_update.destroy }
  end

  def last_day_present
    access_logs.order("access_date DESC").first.access_date unless access_logs.empty?
  end

  def last_day_present_formatted
    last_day_present ? last_day_present.strftime("%m/%d/%Y") : "n/a"
  end

  def self.find_by_key(rfid_key)
    Member.where("LOWER(rfid) = ?", rfid_key.downcase).first
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

  def self.members_absent(weeks)
    days = weeks * 7
    now = Date.current
    Member.where("member_type = 'current' AND billing_plan <> 'supporter'").inject([]) do | members, member |
      if member.access_logs.order("access_date DESC").first.nil?
        members << member
      else
        if now - member.access_logs.order("access_date DESC").first.access_date >= days
          members << member
        end
      end
      members
    end
  end

end
