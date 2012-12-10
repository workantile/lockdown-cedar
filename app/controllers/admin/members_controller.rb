class Admin::MembersController < ApplicationController
	before_filter :authenticate_admin!

	def index
		params[:type] ||= 'current'
		params[:plan] ||= 'all'
		case true
		when (params[:type] == 'all' && params[:plan] == 'all')
			@members = Member.all
		when (params[:type] == 'all' && params[:plan] != 'all')
			@members = Member.where("billing_plan = ?", params[:plan])
		when (params[:type] != 'all' && params[:plan] == 'all')
			@members = Member.where("member_type = ?", params[:type])
		when (params[:type] != 'all' && params[:plan] != 'all')
			@members = Member.where("member_type = ? and billing_plan = ?", params[:type], params[:plan])
		end
	end

	def new
		@member = Member.new
	end

	def create
		@member = Member.new(params[:member])
    if @member.save
   		redirect_to admin_members_path
   	else
    	render :action => "new"
    end       		
	end

	def edit
		@member = Member.find(params[:id])
	end

	def update
		@member = Member.find(params[:id])
		@member.update_attributes(params[:member])
		if @member.save
			redirect_to admin_members_path
		else
			render :action => "edit"
		end
	end

	def destroy
		@member = Member.find(params[:id])
		@member.destroy
	  msg = 'member was successfully deleted'
		redirect_to admin_members_path
	end

end
