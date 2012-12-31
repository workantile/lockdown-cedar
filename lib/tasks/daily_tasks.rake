namespace :daily_tasks do
	desc "take snapshot of membership data"
	task :take_snapshot => :environment do
		Snapshot.take_snapshot
	end

end