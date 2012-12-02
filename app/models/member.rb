class Member < ActiveRecord::Base
	MEMBER_TYPES = ['full','full - no work','affiliate','student','key-only']

  attr_accessible :first_name, :last_name, :email, :rfid, :member_type, :anniversary_date

  validates_presence_of :first_name, :last_name, :email, :member_type
  validates_uniqueness_of :email, :rfid

  validates :member_type, :inclusion => {:in => MEMBER_TYPES, :message => "%{value} is not a valid member type"}

  default_scope order("first_name ASC, last_name ASC")

  before_save :set_default_anniversary_date

  def full_name
  	[first_name, last_name].join(' ')
  end

  def set_default_anniversary_date
  	self.anniversary_date ||= Date.today
  end
  
end
