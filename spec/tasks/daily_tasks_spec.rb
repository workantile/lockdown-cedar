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
			expect(Snapshot).to receive(:take_snapshot).once
			run_rake_task
		end
	end

	describe "send absence email" do
		let :run_rake_task do
			Rake::Task["daily_tasks:send_absence_email"].reenable
			Rake.application.invoke_task "daily_tasks:send_absence_email"
		end

		it "checks for abesnt members" do
			expect(Member).to receive(:members_absent)
			run_rake_task
		end

		it "sends an email to the shoutout committee if there are absent members" do
			absent_members = [stub_model(Member)]
			allow(Member).to receive(:members_absent) { absent_members }
			expect(ShoutOutEmail).to receive(:absent_members_email).and_return(double("mailer", :deliver => true))			
			run_rake_task
		end

		it "does not send an email to the shoutout committee if there are no absent members" do
			allow(Member).to receive(:members_absent) { [] }
			expect(ShoutOutEmail).not_to receive(:absent_members_email)
			run_rake_task
		end
	end

end
