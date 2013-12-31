class RenameAllMembers < ActiveRecord::Migration
  def change
    rename_table :all_members, :all_member_events
  end
end
