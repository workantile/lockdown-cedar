class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone

  def after_sign_in_path_for(resource)
  	admin_admins_path
  end
  
  def set_time_zone
  	Time.zone = "America/New_York"
  end
end
