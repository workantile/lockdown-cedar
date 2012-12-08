class AccessLog < ActiveRecord::Base
  attr_accessible :access_granted, :msg, :member, :door, :member_name, :member_type, 
  								:billing_plan, :door_name

  belongs_to :door
  belongs_to :member

	default_scope where(:access_granted => true).order("created_at DESC")

  after_initialize :set_date

  def set_date
  	self.access_date = Date.today
  end

end
