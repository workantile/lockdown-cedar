class Admin::DoorControllersController < ApplicationController
	before_filter :authenticate_admin!
	respond_to :html, :js

	def index
		@door_controllers = DoorController.all
	end

	def new
		@door_controller = DoorController.new
	end
	
	def create
		@door_controller = DoorController.new(params[:door_controller])
    if @door_controller.save
   		redirect_to admin_door_controllers_path
   	else
    	render :action => "new"
    end       		
	end

	def edit
		@door_controller = DoorController.find(params[:id])
	end

	def update
		@door_controller = DoorController.find(params[:id])
		@door_controller.update_attributes(params[:door_controller])
		if @door_controller.save
			redirect_to admin_door_controllers_path
		else
			render :action => "edit"
		end
	end

	def destroy
		@door_controller = DoorController.find(params[:id])
		@door_controller.destroy
	  msg = 'door controller was successfully deleted'
		redirect_to admin_door_controllers_path
	end

end