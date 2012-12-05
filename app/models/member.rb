class Member < ActiveRecord::Base
	MEMBER_TYPES = ['full','full - no work','affiliate','student','non-member']

  attr_accessible :first_name, :last_name, :email, :rfid, :member_type, :anniversary_date

  validates_presence_of :first_name, :last_name, :email, :rfid, :member_type
  validates_uniqueness_of :email, :rfid

  validates :member_type, :inclusion => {:in => MEMBER_TYPES, :message => "%{value} is not a valid member type"}

  after_initialize :set_default_anniversary_date

  default_scope order("first_name ASC, last_name ASC")

  scope :all_members, where("member_type <> 'non-member'")
  scope :full_members, where(:member_type => 'full')
  scope :full_no_work_members, where(:member_type => 'full - no work')
  scope :affiliate_members, where(:member_type => 'affiliate')
  scope :student_members, where(:member_type => 'student')
  scope :non_members, where(:member_type => 'non-member')

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
  
  def self.grant_access?(rfid, door_address)
    member = find_by_rfid(rfid)
    door = Door.find_by_address(door_address)

    if member && door
      AccessLog.create(:member => member,
                       :door => door,
                       :member_name => member.full_name,
                       :member_type => member.member_type,
                       :door_name => door.name,
                       :access_granted => true)
      true
    else
      AccessLog.create(:member => member,
                       :door => door,
                       :member_name => member.try(:full_name),
                       :member_type => member.try(:member_type),
                       :door_name => door.try(:name),
                       :msg => "rfid used was #{rfid}, door address was #{door_address}",
                       :access_granted => false)
      false
    end
  end

end
