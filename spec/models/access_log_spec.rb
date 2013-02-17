require 'spec_helper'

describe AccessLog do
	describe "expected attributes" do
		before (:each) do
			@access_log = FactoryGirl.create(:log_success)
		end

		it { should respond_to :access_date }
		it { should respond_to :access_granted }
		it { should respond_to :msg }
		it { should respond_to :member_name }
		it { should respond_to :member_type }
		it { should respond_to :billing_plan }
		it { should respond_to :door_controller_location }

		it { should belong_to :member }
		it { should belong_to :door_controller }
	end

	it "should save the access_date in local time" do
		a_date = Date.new(2012, 1, 15)
		Timecop.freeze(2012, 1, 15, 22, 0 ,0)
		access_log = AccessLog.create
		AccessLog.where(:access_date => a_date).count.should eq(1)
	end
	
	it "should not override access_date" do
		Timecop.freeze(2012, 1, 15, 22, 0 ,0)
		another_date = Date.new(2012, 1, 1)
		access_log = FactoryGirl.create(:log_success, :access_date => another_date)
		access_log.access_date.should eq(another_date)
	end

  describe ".export_to_csv" do 
    it "should return a comma-separated string containing records for the dates specified" do
			Timecop.freeze(2013, 1, 1, 22, 0 ,0)
			FactoryGirl.create(:log_success)
			Timecop.freeze(2013, 1, 31, 22, 0 ,0)
			FactoryGirl.create(:log_success)
			Timecop.freeze(2013, 2, 1, 22, 0 ,0)
			FactoryGirl.create(:log_success)

      the_result = AccessLog.export_to_csv(Date.new(2013, 1, 1)..Date.new(2013, 1, 31))
      the_result.should match(/,2013-01-01,/)
      the_result.should match(/,2013-01-31,/)
      the_result.should_not match(/,2013-02-01,/)
    end

  end
end
