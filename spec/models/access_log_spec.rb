require 'rails_helper'

describe AccessLog do
	describe "expected attributes" do
		before (:each) do
			@access_log = FactoryGirl.create(:log_success)
		end

		it { is_expected.to respond_to :access_date }
		it { is_expected.to respond_to :access_granted }
		it { is_expected.to respond_to :msg }
		it { is_expected.to respond_to :member_name }
		it { is_expected.to respond_to :member_type }
		it { is_expected.to respond_to :billing_plan }
		it { is_expected.to respond_to :door_controller_location }

		it { is_expected.to belong_to :member }
		it { is_expected.to belong_to :door_controller }
		it { is_expected.to respond_to :billable }
	end

	it "should save the access_date in local time" do
		a_date = Date.new(2012, 1, 15)
		Timecop.freeze(2012, 1, 15, 22, 0 ,0)
		access_log = AccessLog.create
		Timecop.return
		expect(AccessLog.where(:access_date => a_date).count).to eq(1)
	end

	it "should not override access_date" do
		Timecop.freeze(2012, 1, 15, 22, 0 ,0)
		another_date = Date.new(2012, 1, 1)
		access_log = FactoryGirl.create(:log_success, :access_date => another_date)
		Timecop.return
		expect(access_log.access_date).to eq(another_date)
	end

  describe "#export_to_csv" do
    it "should return a comma-separated string containing records for the dates specified" do
			Timecop.freeze(2013, 1, 1, 22, 0 ,0)
			FactoryGirl.create(:log_success)
			Timecop.freeze(2013, 1, 31, 22, 0 ,0)
			FactoryGirl.create(:log_success)
			Timecop.freeze(2013, 2, 1, 22, 0 ,0)
			FactoryGirl.create(:log_success)
			Timecop.return

      the_result = AccessLog.export_to_csv(Date.new(2013, 1, 1)..Date.new(2013, 1, 31))
      expect(the_result).to match(/,2013-01-01,/)
      expect(the_result).to match(/,2013-01-31,/)
      expect(the_result).not_to match(/,2013-02-01,/)
    end

  end

  describe "#free_day?" do
  	it "should return true if access_date is a Sunday" do
  		Timecop.freeze(2017, 06, 04, 0, 0)
  		access_log = FactoryGirl.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(true)
  	end

  	it "should return true if access was during an all member event" do
  		free_access = DateTime.new(2017, 06, 05, 12, 0, 0)
  		FactoryGirl.create(:all_member_event, scheduled: free_access)
  		Timecop.freeze(free_access)
  		access_log = FactoryGirl.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(true)
  	end

  	it "should return false if access was not during an all member event" do
  		free_access = DateTime.new(2017, 06, 05, 12, 0, 0)
  		FactoryGirl.create(:all_member_event, scheduled: free_access)
  		Timecop.freeze(2017, 06, 06, 10, 0, 0)
  		access_log = FactoryGirl.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(false)
  	end
  end
end
