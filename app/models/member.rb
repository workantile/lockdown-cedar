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

  scope :all_members, where(:member_type => 'current')
  scope :full_members, where(:member_type => 'current', :billing_plan => 'full')
  scope :full_no_work_members, where(:member_type => 'current', :billing_plan => 'full - no work')
  scope :affiliate_members, where(:member_type => 'current', :billing_plan => 'affiliate')
  scope :student_members, where(:member_type => 'current', :billing_plan => 'student')
  scope :non_members, where("member_type <> 'current'")

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
