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
    Admin.create(:email => 'twbrandt@gmail.com', :password => 'v&63Q`N%hI_-m8;U],rd',
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

  desc 'Fix up access log'
  task :fixup_access_log => :environment do
    @logs = AccessLog.all
    @logs.each do |log|
      unless log.member_id.nil?
        if log.billing_plan.nil?
          begin
            member = Member.find(log.member_id)
            log.member_type = member.member_type
            log.billing_plan = member.billing_plan
            log.save!
          rescue
            puts log.member_id.to_s + " does not exist"
          end
        end
      end
    end
  end

  desc 'set dates/times to local time'
  task :set_to_local => :environment do
    @logs = AccessLog.all
    @logs.each do |log|
      et = log.created_at.ago(18000)
      log.access_date = et.to_date
      log.save
    end
  end

  desc 'set create, upddate dates/times to local time'
  task :set_created_at_to_local => :environment do
    @logs = AccessLog.all
    @logs.each do |log|
      log.created_at = log.created_at.ago(18000)
      log.updated_at = log.updated_at.ago(18000)
      log.save
    end
  end
 end
