require 'rails_helper'

describe PendingUpdate do
	it { is_expected.to respond_to(:description) }
	it { is_expected.to respond_to(:delayed_job_id) }
	it { is_expected.to belong_to(:member) }

	it "should delete associated delayed_job object when it is destroyed" do
		delayed_job = Delayed::Job.create
		pending_update = FactoryBot.create(:pending_update, :delayed_job_id => delayed_job.id)
		pending_update.destroy
		expect(Delayed::Job.exists?(delayed_job.id)).to be_falsey
	end
end
