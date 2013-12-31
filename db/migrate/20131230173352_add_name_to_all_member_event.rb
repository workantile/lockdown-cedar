class AddNameToAllMemberEvent < ActiveRecord::Migration
  def change
    add_column :all_member_events, :name, :string
    rename_column :all_member_events, :event, :scheduled
  end
end
