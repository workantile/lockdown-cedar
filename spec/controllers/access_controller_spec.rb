require 'spec_helper'

describe AccessController do
	let!(:member) { stub_model(Member, :member_type => 'current', :billing_plan => 'full', :rfid => '1234',
		:key_enabled => true, :email => 'foo@bar.com') }
	let!(:door_controller) { stub_model(DoorController, :address => "abc", :success_response => "OK") }

	before(:each) do
		Member.stub(:find_by_key) { member }
		DoorController.stub(:find_by_address) { door_controller }
	end

	it "assigns to door_controller" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		assigns(:door_controller).should eq(door_controller)
	end

	it "assigns to member" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		assigns(:member).should eq(member)
	end

	it "sees if the member should be granted access" do
		member.should_receive(:access_enabled?)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "gets door controller's success response if member should be granted access" do
		door_controller.should_receive(:success_response)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "gets door controller's error response if member should not be granted access" do
		member.stub(:access_enabled?) { false }
		door_controller.should_receive(:error_response)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "checks if an all member event is happening" do
		AllMemberEvent.should_receive(:event_happening?)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access" do
		AccessLog.should_receive(:create).with(
				:member => member,
				:door_controller => door_controller,
				:member_name => member.full_name,
				:member_type => member.member_type,
				:billing_plan => member.billing_plan,
				:door_controller_location => door_controller.location,
				:access_granted => true,
				:billable => true
			)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access with the billable flag set to false if an event is happening" do
		AllMemberEvent.stub(:event_happening?) { true }
		AccessLog.should_receive(:create).with(
				:member => member,
				:door_controller => door_controller,
				:member_name => member.full_name,
				:member_type => member.member_type,
				:billing_plan => member.billing_plan,
				:door_controller_location => door_controller.location,
				:access_granted => true,
				:billable => false
			)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access with the billable flat set to false if it is Sunday" do
		Timecop.freeze(2016, 7, 31, 22, 0 ,0) do
			AllMemberEvent.stub(:event_happening?) { false }
			AccessLog.should_receive(:create).with(
					:member => member,
					:door_controller => door_controller,
					:member_name => member.full_name,
					:member_type => member.member_type,
					:billing_plan => member.billing_plan,
					:door_controller_location => door_controller.location,
					:access_granted => true,
					:billable => false
				)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end
	end

	context "sending usage emails" do
    before(:each) do
      Delayed::Worker.delay_jobs = false
    end
    after(:each) do
      Delayed::Worker.delay_jobs = true
    end      

		it "sees if the member should be sent an email" do
			member.should_receive(:send_usage_email?)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end	

		it "sends a free day pass email if the member's billable usage this month is 0" do
			member.stub(:send_usage_email?) { true }
			member.stub(:billable_usage_this_month) { 0 }
      MemberEmail.should_receive(:free_day_pass_use).with(member).and_return(double("mailer", :deliver => true))
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sends a billable day pass email if the member's billable usage this month > 0" do
			member.stub(:send_usage_email?) { true }
			member.stub(:billable_usage_this_month) { 1 }
      MemberEmail.should_receive(:billable_day_pass_use).with(member).and_return(double("mailer", :deliver => true))
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sets the email sent date to the current date" do
			member.stub(:send_usage_email?) { true }
			member.stub(:billable_usage_this_month) { 1 }
			member.should_receive(:usage_email_sent=).with(Date.current)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sends no emails during an all-members event" do
			AllMemberEvent.stub(:event_happening?) { true }
			member.stub(:send_usage_email?) { true }
			member.stub(:billable_usage_this_month) { 0 }
      MemberEmail.should_not_receive(:free_day_pass_use).with(member)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

	end

	it "renders the show template" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		response.should render_template('show')
	end

end