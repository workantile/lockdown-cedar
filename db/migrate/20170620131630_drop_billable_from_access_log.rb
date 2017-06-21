class DropBillableFromAccessLog < ActiveRecord::Migration
  def change
    remove_column :access_logs, :billable
  end
end
