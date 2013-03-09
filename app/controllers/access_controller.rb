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
		if @member.access_enabled?
			@response = @door_controller.success_response
			send_email
		else
			@response = @door_controller.error_response
		end
		render :content_type => "text/plain", :layout => false
	end

	def send_email
		member = Member.find_by_rfid(params[:rfid])
    member ||= Member.find_by_rfid(params[:rfid].downcase)
		member.send_usage_email
	end

end
