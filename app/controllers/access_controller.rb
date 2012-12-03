class AccessController < ApplicationController
	def show
		begin
			@member = Member.find_by_rfid!(params[:rfid])
			@door = Door.find_by_address!(params[:address])
			render :text =>'OK'
		rescue
			render :text => 'ERROR'
		end
	end

end
