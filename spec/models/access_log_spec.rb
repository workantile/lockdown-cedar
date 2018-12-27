require 'rails_helper'

describe AccessLog do
	describe "expected attributes" do
		before (:each) do
			@access_log = FactoryBot.create(:log_success)
		end

		it { is_expected.to respond_to :access_date }
    it { is_expected.to respond_to :access_date_time }
		it { is_expected.to respond_to :access_granted }
		it { is_expected.to respond_to :msg }
		it { is_expected.to respond_to :member_name }
		it { is_expected.to respond_to :member_type }
		it { is_expected.to respond_to :billing_plan }
		it { is_expected.to respond_to :door_controller_location }

		it { is_expected.to belong_to :member }
		it { is_expected.to belong_to :door_controller }
	end

  describe "#access_date_time" do
    before(:each) do
      Timecop.freeze(2017, 5, 1, 10, 0 ,0)
    end
    after(:each) do
      Timecop.return
    end

    it "should set be set to current time if it is not specified" do
      AccessLog.create
      expect(AccessLog.first.access_date_time).to eq(DateTime.now)
    end

    it "should be set to specified time if it is specified" do
      a_time = DateTime.new(2017, 4, 30, 13, 0, 0)
      AccessLog.create(access_date_time: a_time)
      expect(AccessLog.first.access_date_time).to eq(a_time)
    end
  end

  describe "#access_date" do
    it "should be set to the date portion of #access_date_time" do
      Timecop.freeze(2017, 5, 1, 10, 0 ,0)
      AccessLog.create
      expect(AccessLog.first.access_date).to eq(DateTime.now.to_date)
      Timecop.return
    end
  end

  describe "#export_to_csv" do
    it "should return a comma-separated string containing records for the dates specified" do
			Timecop.freeze(2013, 1, 1, 22, 0 ,0)
			FactoryBot.create(:log_success)
			Timecop.freeze(2013, 1, 31, 22, 0 ,0)
			FactoryBot.create(:log_success)
			Timecop.freeze(2013, 2, 1, 22, 0 ,0)
			FactoryBot.create(:log_success)
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
  		access_log = FactoryBot.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(true)
  	end

  	it "should return true if access was during an all member event" do
  		free_access = DateTime.new(2017, 06, 05, 12, 0, 0)
  		FactoryBot.create(:all_member_event, scheduled: free_access)
  		Timecop.freeze(free_access)
  		access_log = FactoryBot.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(true)
  	end

  	it "should return false if access was not during an all member event" do
  		free_access = DateTime.new(2017, 06, 05, 12, 0, 0)
  		FactoryBot.create(:all_member_event, scheduled: free_access)
  		Timecop.freeze(2017, 06, 06, 10, 0, 0)
  		access_log = FactoryBot.create(:log_success)
  		Timecop.return
  		expect(access_log.free_day?).to eq(false)
  	end
  end
end
