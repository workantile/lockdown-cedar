require "spec_helper"
require "rake"

describe "daily_tasks namespace" do
	before(:each) do
		Rake.application.rake_require "tasks/daily_tasks"
		Rake::Task.define_task(:environment)
	end

	describe "take_snapshot task" do
		let :run_rake_task do
			Rake::Task["daily_tasks:take_snapshot"].reenable
			Rake.application.invoke_task "daily_tasks:take_snapshot"
		end

		it "should take a snapshot of membership data" do
			Snapshot.should_receive(:take_snapshot).once
			run_rake_task
		end

	end
end
