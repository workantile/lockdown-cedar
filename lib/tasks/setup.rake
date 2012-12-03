require 'csv'

namespace :data do
	desc 'Import old key data'
  task :import_old_data => :environment do

    read_members.each do |member|
      puts "Saving member:  #{member.full_name}"
      member.save! rescue puts "Error saving member #{member.full_name}"

    end
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
 end
