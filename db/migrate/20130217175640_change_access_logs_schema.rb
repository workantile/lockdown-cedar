class ChangeAccessLogsSchema < ActiveRecord::Migration
  def up
  	rename_column :access_logs, :door_name, :door_controller_location
  	remove_column :access_logs, :door_id
  	add_column :access_logs, :door_controller_id, :integer
  end

  def down
  	rename_column :access_logs, :door_controller_location, :door_name
  	remove_column :access_logs, :door_controller_id
  	add_column :access_logs, :door_id, :integer
  end
end
