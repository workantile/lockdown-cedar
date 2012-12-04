class AddFieldsToAccessLogs < ActiveRecord::Migration
  def change
  	add_column :access_logs, :member_name, :string
  	add_column :access_logs, :member_type, :string
  	add_column :access_logs, :door_name, :string
  end
end
