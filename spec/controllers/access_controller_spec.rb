require 'spec_helper'

describe AccessController do
	before(:each) do
		@member = stub_model(Member, :member_type => 'current', :billing_plan => 'full', :rfid => '1234')
		Member.stub(:find_by_rfid) { @member }
		@door_controller = stub_model(DoorController, :address => "abc", :success_response => "OK")
		DoorController.stub(:find_by_address) { @door_controller }
	end

	it "assigns to @door_controller" do
		get :show, :address => @door_controller.address, :rfid => @member.rfid
		assigns(:door_controller).should eq(@door_controller)
	end

	it "assigns to @member" do
		get :show, :address => @door_controller.address, :rfid => @member.rfid
		assigns(:member).should eq(@member)
	end

	it "sees if the member should be granted access" do
		@member.should_receive(:access_enabled?)
		get :show, :address => @door_controller.address, :rfid => @member.rfid
	end

	it "sees if the member should be sent an email" do
		@member.should_receive(:send_usage_email)
		get :show, :address => @door_controller.address, :rfid => @member.rfid
	end	

	it "renders the show template" do
		get :show, :address => @door_controller.address, :rfid => @member.rfid
		response.should render_template('show')
	end

end