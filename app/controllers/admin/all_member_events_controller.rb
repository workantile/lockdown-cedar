class Admin::AllMemberEventsController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html, :js

  def index
    @all_member_events = AllMemberEvent.all
  end

  def new
    @all_member_event = AllMemberEvent.new
  end
  
  def create
    @all_member_event = AllMemberEvent.new(params[:all_member_event])
    if @all_member_event.save
      redirect_to admin_all_member_events_path
    else
      render :action => "new"
    end           
  end

  def edit
    @all_member_event = AllMemberEvent.find(params[:id])
  end

  def update
    @all_member_event = AllMemberEvent.find(params[:id])
    @all_member_event.update_attributes(params[:all_member_event])
    if @all_member_event.save
      redirect_to admin_all_member_events_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @all_member_event = AllMemberEvent.find(params[:id])
    @all_member_event.destroy
    msg = 'all member event was successfully deleted'
    redirect_to admin_all_member_events_path
  end

end