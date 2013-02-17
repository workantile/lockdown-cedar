require 'spec_helper'

describe AccessController do
	before(:each) do
		@member = FactoryGirl.create(:full_member)
		@door_controller = FactoryGirl.create(:door_controller)
		get :show, :address => @door_controller.address, :rfid => @member.rfid
	end

	it "assigns to @door_controller" do
		assigns(:door_controller).should eq(@door_controller)
	end

	it "renders the show template" do
		response.should render_template('show')
	end

end