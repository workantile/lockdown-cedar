require 'spec_helper'

describe AccessController do
	before(:each) do
		@member = FactoryGirl.create(:full_member)
		@door_controller = FactoryGirl.create(:door_controller)
	end

	it "renders 'OK' when a valid member wants access" do
		get :show, :rfid => @member.rfid, :address => @door_controller.address
		response.body.should == 'OK'
	end

	it "renders 'ERROR' when a non-existant member wants access" do
		rfid = @member.rfid
		@member.destroy
		get :show, :rfid => rfid, :address => @door_controller.address
		response.body.should == 'ERROR'
	end
end