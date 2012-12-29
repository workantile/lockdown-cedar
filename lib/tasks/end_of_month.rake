namespace :end_of_month do
	desc "take monthly snapshot of monthly membership data"
	task :take_snapshot => :environment do
		# Note - we are checking for the last day of the month because the heroku scheduler
		# can only schedule things by the day, hour, or every 10 minutes. So the task hast
		# to see if it is the end of the mondh.
		Snapshot.take_snapshot if last_day?
	end

	def last_day?
		Date.today == Date.today.end_of_month
	end
end