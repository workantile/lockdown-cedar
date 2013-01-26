class PendingUpdate < ActiveRecord::Base
  attr_accessible :description, :member, :delayed_job_id
	belongs_to :member

	before_destroy :delete_delayed_job

	def delete_delayed_job
		Delayed::Job.delete(self.delayed_job_id)
	end
end
