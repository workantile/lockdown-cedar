require 'rails_helper'

describe AccessController do
	let!(:member) {
		FactoryBot.create(
			:member,
			member_type: 'current',
			billing_plan: 'full',
			rfid: '1234',
			key_enabled: true,
			email: 'foo@bar.com')
	}
	let!(:door_controller) {
		FactoryBot.create(:door_controller, address: "abc", success_response: "OK")
	}

	before(:each) do
		allow(Member).to receive(:find_by_key).and_return(member)
		allow(DoorController).to receive(:find_by_address).and_return(door_controller)
	end

	it "assigns to door_controller" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		expect(assigns(:door_controller)).to eq(door_controller)
	end

	it "assigns to member" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		expect(assigns(:member)).to eq(member)
	end

	it "sees if the member should be granted access" do
		expect(member).to receive(:access_enabled?)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "gets door controller's success response if member should be granted access" do
		expect(door_controller).to receive(:success_response)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "gets door controller's error response if member should not be granted access" do
		allow(member).to receive(:access_enabled?) { false }
		expect(door_controller).to receive(:error_response)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "checks if an all member event is happening" do
		expect(AllMemberEvent).to receive(:event_happening?)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access" do
		expect(AccessLog).to receive(:create).with(
				:member => member,
				:door_controller => door_controller,
				:member_name => member.full_name,
				:member_type => member.member_type,
				:billing_plan => member.billing_plan,
				:door_controller_location => door_controller.location,
				:access_granted => true
			)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access with the billable flag set to false if an event is happening" do
		allow(AllMemberEvent).to receive(:event_happening?) { true }
		expect(AccessLog).to receive(:create).with(
				:member => member,
				:door_controller => door_controller,
				:member_name => member.full_name,
				:member_type => member.member_type,
				:billing_plan => member.billing_plan,
				:door_controller_location => door_controller.location,
				:access_granted => true
			)
		get :show, :address => door_controller.address, :rfid => member.rfid
	end

	it "logs the access with the billable flat set to false if it is Sunday" do
		Timecop.freeze(2016, 7, 31, 22, 0 ,0) do
			allow(AllMemberEvent).to receive(:event_happening?) { false }
			expect(AccessLog).to receive(:create).with(
					:member => member,
					:door_controller => door_controller,
					:member_name => member.full_name,
					:member_type => member.member_type,
					:billing_plan => member.billing_plan,
					:door_controller_location => door_controller.location,
					:access_granted => true
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
			expect(member).to receive(:send_usage_email?)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sends a free day pass email if the member's billable usage this month is 0" do
			allow(member).to receive(:send_usage_email?) { true }
			allow(member).to receive(:billable_usage_this_month) { 0 }
      expect(MemberEmail).to receive(:free_day_pass_use).with(member).and_return(double("mailer", :deliver => true))
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sends a billable day pass email if the member's billable usage this month > 0" do
			allow(member).to receive(:send_usage_email?) { true }
			allow(member).to receive(:billable_usage_this_month) { 1 }
      expect(MemberEmail).to receive(:billable_day_pass_use).with(member).and_return(double("mailer", :deliver => true))
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sets the email sent date to the current date" do
			allow(member).to receive(:send_usage_email?) { true }
			allow(member).to receive(:billable_usage_this_month) { 1 }
			expect(member).to receive(:usage_email_sent=).with(Date.current)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

		it "sends no emails during an all-members event" do
			allow(AllMemberEvent).to receive(:event_happening?) { true }
			allow(member).to receive(:send_usage_email?) { true }
			allow(member).to receive(:billable_usage_this_month) { 0 }
      expect(MemberEmail).not_to receive(:free_day_pass_use).with(member)
			get :show, :address => door_controller.address, :rfid => member.rfid
		end

	end

	it "renders the show template" do
		get :show, :address => door_controller.address, :rfid => member.rfid
		expect(response).to render_template('show')
	end

end