require 'csv'

class AccessLog < ActiveRecord::Base
  attr_accessible :access_granted, :msg, :member, :door_controller, :member_name, :member_type,
  								:billing_plan, :door_controller_location, :access_date_time

  belongs_to :door_controller
  belongs_to :member

	default_scope { where(:access_granted => true).order("created_at DESC") }

  before_save :set_access_date_time

  def set_access_date_time
    # We are using both a date object and a datetime object to simplify reporting
    # and SQL queries.
    self.access_date_time ||= DateTime.now
    self.access_date = self.access_date_time.to_date
  end

  def free_day?
    access_date.sunday? ||
    AllMemberEvent.where(
      scheduled: access_date_time.beginning_of_day ..(access_date_time + 1.hour)
    ).exists?
  end

  def self.export_to_csv(date_range)
    logs = where(access_date: date_range)
    headers = logs.first.attributes.collect { |attribute| attribute[0] }
    CSV.generate do |csv|
      csv << headers
      logs.each do |member|
        csv << headers.collect { |attribute| member[attribute]}
      end
    end
  end

end
