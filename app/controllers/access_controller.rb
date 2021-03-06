class AccessController < ApplicationController
	def show
		@door_controller = DoorController.find_by_address(params[:address])
		if @door_controller
			grant_access
		else
			render :text => 'ERROR'
		end
	end

  def grant_access
    @member = Member.find_by_key(params[:rfid])
    @free_day = AllMemberEvent.event_happening? || Date.today.sunday?

    if @member && should_grant_access?
			@response = @door_controller.success_response
  		log_access
			send_email if @member.send_usage_email? && !@free_day
		else
			@response = @door_controller.error_response
		end
		render :content_type => "text/plain", :layout => false
	end

	def log_access
    AccessLog.create(:member => @member,
                   :door_controller => @door_controller,
                   :member_name => @member.full_name,
                   :member_type => @member.member_type,
                   :billing_plan => @member.billing_plan,
                   :door_controller_location => @door_controller.location,
                   :access_granted => true)
  end

  def send_email
    if @member.billable_usage_this_month == 0
      MemberEmail.delay.free_day_pass_use(@member)
    else
      MemberEmail.delay.billable_day_pass_use(@member)
    end
    @member.usage_email_sent = Date.current
    @member.save
  end

  def should_grant_access?
    return true if @member.access_enabled? && @member.billing_plan != "supporter"
    return true if @member.access_enabled? && @member.billing_plan == "supporter" && @free_day
    return false
  end
end
