class Door < ActiveRecord::Base
  attr_accessible :address, :name, :shared_secret

  validates_presence_of :address, :name
  validates_uniqueness_of :address, :name
  
  has_many :access_logs
  
end
