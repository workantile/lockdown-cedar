require 'csv'

namespace :data do
	desc 'Import old key data'
  task :import_old_data => :environment do

    read_members.each do |member|
      puts "Saving member:  #{member.full_name}"
      member.save! rescue puts "Error saving member #{member.full_name}"

    end
  end

  desc 'set up initial admin'
  task :setup_initial_admin do
    Admin.create(:email => 'twbrandt@gmail.com', :password -> 'v&63Q`N%hI_-m8;U],rd',
                :password_confirmation => 'v&63Q`N%hI_-m8;U],rd')
  end

  def read_members
  	n = 0
    CSV.readlines('db/import/keys.csv', {headers: true}).collect do |member_data|
      unless member_data.empty?
        member = Member.new
        member.first_name, member.last_name = member_data[2].split(' ',2)
        member.rfid = member_data[1]
        member.email = "foo#{n}@bar.com"
        n += 1
        temp_date = Date.strptime(member_data[3][0..9], "%Y-%m-%d")
				member.anniversary_date = temp_date.strftime("%m/%d/%Y")     
				member.member_type = 'full'
        member
      end
    end
  end

  desc 'Set up doors'
  task :setup_doors => :environment do
    Door.create!(:name => 'Bank', :address => 'deadbeef01')
    Door.create!(:name => 'Alley', :address => 'deadbeef00')
  end
 end
