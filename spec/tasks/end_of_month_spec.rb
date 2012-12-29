require "spec_helper"
require "rake"

describe "end_of_month namespace" do
	before(:each) do
		Rake.application.rake_require "tasks/end_of_month"
		Rake::Task.define_task(:environment)
		Time.zone = "America/New_York"
	end

	describe "take_snapshot task" do
		let :run_rake_task do
			Rake::Task["end_of_month:take_snapshot"].reenable
			Rake.application.invoke_task "end_of_month:take_snapshot"
		end

		it "should take a snapshot of membership data" do
			Timecop.freeze(Date.new(2012,11,30))
			Snapshot.should_receive(:take_snapshot).once
			run_rake_task
		end

		it "should only run on the last day of the month" do
			Timecop.freeze(Date.new(2012,11,29))
			Snapshot.should_receive(:take_snapshot).never
			run_rake_task
		end

	end
end
