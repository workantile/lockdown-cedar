class Admin::AdminsController < ApplicationController
	before_filter :authenticate_admin!

	def index
		@admins = Admin.all
	end

	def new
		@admin = Admin.new
	end

	def create
		@admin = Admin.new(params[:admin])
    if @admin.save
     	redirect_to admin_admins_path
    else
    	render :action => "new"
    end    
	end

	def edit
    @admin = Admin.find(params[:id])
	end

	def update
    @admin = Admin.find(params[:id])
    @admin.update_attributes(params[:admin])
    if @admin.save
      redirect_to admin_admins_path
    else
      render :action => "edit"
    end    
	end

  def destroy
	  Admin.find(params[:id]).destroy
	  msg = 'admin was successfully deleted'
	  redirect_to(admin_admins_path, :notice => msg)
  end
  
end
