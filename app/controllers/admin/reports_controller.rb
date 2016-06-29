class Admin::ReportsController < ApplicationController
  before_filter :authenticate_admin!
	respond_to :html, :js

	def index
		params[:start_date] ||= Date.today.prev_month.strftime("%m/%d/%Y")
		params[:end_date] ||= Date.today.strftime("%m/%d/%Y")
		if params[:id]
			@logs = AccessLog.where(:access_date => date_range, :member_id => params[:id])
		else
			@logs = AccessLog.where(:access_date => date_range)
		end
		respond_with @logs
	end

	def export
    filename = "access_log.csv"
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
		render :text => AccessLog.export_to_csv(date_range)
	end

	def date_range
		start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
		end_date = Date.strptime(params[:end_date], "%m/%d/%Y")
		start_date = end_date if (start_date <=> end_date) == 1
		start_date..end_date
	end

end
