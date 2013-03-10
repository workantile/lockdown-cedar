namespace :daily_tasks do
	desc "take snapshot of membership data"
	task :take_snapshot => :environment do
		Snapshot.take_snapshot
	end

  desc "send email to shoutout committee of people absent for over 3 weeks"
  task :send_absence_email => :environment do
    absent_members = Member.members_absent(3)
    ShoutOutEmail.absent_members_email(absent_members).deliver unless absent_members.nil? || absent_members.empty?
  end

end