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
		@member = Member.find_by_rfid(params[:rfid])
    @member ||= Member.find_by_rfid(params[:rfid].downcase)
		if @member && @member.access_enabled?
			@response = @door_controller.success_response
			log_access
			send_email
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
		member = Member.find_by_rfid(params[:rfid])
    member ||= Member.find_by_rfid(params[:rfid].downcase)
		member.send_usage_email
	end

end
