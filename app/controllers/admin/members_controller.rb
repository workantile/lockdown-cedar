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
		@pending_updates = @member.pending_updates
	end

	def update
		@member = Member.find(params[:id])
		find_delayed_updates
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

	def destroy_delayed_updates
		@member = Member.find(params[:id])
		@member.destroy_pending_updates
		redirect_to admin_members_path
	end

	def find_delayed_updates
		if params[:member_type_timing] == 'end_billing_period'
			@member.delay_update(:member_type, params[:member][:member_type])
			params[:member].delete(:member_type)
		end
		if params[:billing_plan_timing] == 'end_billing_period'
			@member.delay_update(:billing_plan, params[:member][:billing_plan])
			params[:member].delete(:billing_plan)
		end
	end

end
