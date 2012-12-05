class AccessLog < ActiveRecord::Base
  attr_accessible :access_granted, :msg, :member, :door, :member_name, :member_type, :door_name

  belongs_to :door
  belongs_to :member

  after_initialize :set_date

  def set_date
  	self.access_date = Date.today
  end

end
