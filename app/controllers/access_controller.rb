class AccessController < ApplicationController
	def show
		if Member.grant_access?(params[:rfid], params[:address])
			render :text => 'OK'
		else
			render :text => 'ERROR'
		end
	end

end
