class Admin::MembersController < ApplicationController
	before_filter :authenticate_admin!
	respond_to :html, :js

	def index
		params[:type] ||= 'current'
		params[:plan] ||= 'all'
		@members = Member.lookup_type_plan(params[:type], params[:plan])
		respond_with @members
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

	def billing
		@members = Member.members_to_invoice
	end
	
	def invoiced
		@member = Member.find(params[:id])
		@member.last_date_invoiced = Date.today
		@member.save
		respond_with @member
	end
end
