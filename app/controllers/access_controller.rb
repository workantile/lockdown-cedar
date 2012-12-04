class AccessController < ApplicationController
	def show
		begin
			@member = Member.find_by_rfid!(params[:rfid])
			@door = Door.find_by_address!(params[:address])
			AccessLog.create(:member => @member, :door => @door, :access_granted => true)
			render :text => 'OK'
		rescue
			render :text => 'ERROR'
		end
	end

end
