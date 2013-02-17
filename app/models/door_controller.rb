class DoorController < ActiveRecord::Base
  attr_accessible :address, :location, :success_response, :error_response

  validates_presence_of :address, :location, :success_response, :error_response
  validates_uniqueness_of :address, :location
  
  has_many :access_logs
  
end
