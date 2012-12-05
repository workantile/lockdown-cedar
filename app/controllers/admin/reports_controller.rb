class Admin::ReportsController < ApplicationController

	def index
		@logs = AccessLog.all
	end

end
