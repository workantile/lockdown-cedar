require 'spec_helper'

describe PendingUpdate do
	it { should respond_to(:description) }
	it { should respond_to(:delayed_job_id) }
	it { should belong_to(:member) }

	it "should delete associated delayed_job object when it is destroyed" do
		delayed_job = Delayed::Job.create
		pending_update = FactoryGirl.create(:pending_update, :delayed_job_id => delayed_job.id)
		pending_update.destroy
		Delayed::Job.exists?(delayed_job.id).should be_false
	end
end
