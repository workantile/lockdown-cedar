namespace :end_of_month do
	desc "take snapshot of monthly membership data"
	task :take_snapshot => :environment do
		Snapshot.take_snapshot
	end
end