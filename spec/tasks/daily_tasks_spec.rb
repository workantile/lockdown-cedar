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

	describe "send absence email" do
		let :run_rake_task do
			Rake::Task["daily_tasks:send_absence_email"].reenable
			Rake.application.invoke_task "daily_tasks:send_absence_email"
		end

		it "should find members absent over 3 weeks" do
			Member.should_receive(:members_absent).with(3)
			run_rake_task
		end

		it "sends an email to the shoutout committee" do
			@member = stub_model(Member)
			Member.stub(:members_absent) { [@member] }
			run_rake_task
			ActionMailer::Base.deliveries.last.to.should == ["shoutout@workantile.com"]			
		end
	end

end
