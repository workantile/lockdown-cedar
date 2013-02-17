require 'spec_helper'

describe DoorController do
  before(:each) do
    @door_controller = FactoryGirl.create(:door_controller)
    @door_controller.save
  end

  it { should respond_to :address }
  it { should respond_to :location }
  it { should respond_to :success_response }
  it { should respond_to :error_response}

  it { should validate_presence_of :address }
  it { should validate_presence_of :location }

  it { should validate_uniqueness_of :address }
  it { should validate_uniqueness_of :location }
  
end
