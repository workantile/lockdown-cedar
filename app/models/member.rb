class Member < ActiveRecord::Base
	BILLING_PLANS = ['full','full - no work','affiliate','student','supporter', 'none']
  MEMBER_TYPES = ['current', 'former', 'courtesy key']

  attr_accessible :first_name, :last_name, :email, :rfid, :member_type, :anniversary_date,
                  :billing_plan, :key_enabled, :task, :pay_simple_customer_id, :termination_date

  validates_presence_of :first_name, :last_name, :email, :member_type, :billing_plan
  validates_uniqueness_of :email, :rfid

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
    month_start = Date.new(Date.today.year, Date.today.month, 1)
    month_end = Date.new(Date.today.year, Date.today.month, -1)
    self.access_logs.where("access_date >= ? and access_date <= ?", month_start, month_end).count(:access_date, :distinct => true)
  end

  def usage_this_billing_period
    month_start = Date.new(Date.today.year, Date.today.month, 1)
    month_end = Date.new(Date.today.year, Date.today.month, -1)
    self.access_logs.where(:access_date => self.current_billing_period).count(:access_date, :distinct => true)
  end

  def self.grant_access?(rfid, door_address)
    member = find_by_rfid(rfid)
    door = Door.find_by_address(door_address)
    if member && member.access_enabled? && door
      AccessLog.create(:member => member,
                       :door => door,
                       :member_name => member.full_name,
                       :member_type => member.member_type,
                       :billing_plan => member.billing_plan,
                       :door_name => door.name,
                       :access_granted => true)
      true
    else
      false
    end
  end

end
