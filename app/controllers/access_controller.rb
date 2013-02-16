class AccessController < ApplicationController
	def show
		if Member.grant_access?(params[:rfid], params[:address])
			render :text => 'OK'
			send_email
		else
			render :text => 'ERROR'
		end
	end

	def send_email
		member = Member.find_by_rfid(params[:rfid])
    member ||= Member.find_by_rfid(params[:rfid].downcase)
		member.send_usage_email
	end

end
