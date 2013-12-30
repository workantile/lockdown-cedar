class AddBillableToAccessLog < ActiveRecord::Migration
  def change
    add_column :access_logs, :billable, :boolean, :default => true
  end
end
