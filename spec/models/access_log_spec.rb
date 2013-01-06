require 'spec_helper'

describe AccessLog do
	before (:each) do
		@access_log = FactoryGirl.create(:log_success)
	end

	it { should respond_to :access_date }
	it { should respond_to :access_granted }
	it { should respond_to :msg }
	it { should respond_to :member_name }
	it { should respond_to :member_type }
	it { should respond_to :billing_plan }
	it { should respond_to :door_name }

	it { should belong_to :member }
	it { should belong_to :door }

	it "should save the access_date in local time" do
		a_date = Date.new(2012, 1, 15)
		Timecop.freeze(2012, 1, 15, 22, 0 ,0)
		access_log = AccessLog.create
		AccessLog.where(:access_date => a_date).count.should eq(1)
		AccessLog.all.each { |access_log| puts access_log.inspect }
	end

end
