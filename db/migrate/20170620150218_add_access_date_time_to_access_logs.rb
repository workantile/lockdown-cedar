class AddAccessDateTimeToAccessLogs < ActiveRecord::Migration
  def up
    add_column :access_logs, :access_date_time, :datetime

    AccessLog.find_each do |access_log|
      access_log.access_date_time = access_log.created_at
      access_log.save!
    end
  end

  def down
    remove_column :access_logs, :access_date_time
  end
end
