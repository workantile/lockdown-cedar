require 'csv'

class AccessLog < ActiveRecord::Base
  attr_accessible :access_granted, :msg, :member, :door_controller, :member_name, :member_type, 
  								:billing_plan, :door_controller_location

  belongs_to :door_controller
  belongs_to :member

	default_scope where(:access_granted => true).order("created_at DESC")

  before_save :set_date

  def set_date
  	self.access_date ||= Date.current
  end

  def self.export_to_csv(date_range)
    logs = where(:access_date => date_range)
    headers = logs.first.attributes.collect { |attribute| attribute[0] }
    CSV.generate do |csv|
      csv << headers
      logs.each do |member|
        csv << headers.collect { |attribute| member[attribute]}
      end
    end
  end

end
