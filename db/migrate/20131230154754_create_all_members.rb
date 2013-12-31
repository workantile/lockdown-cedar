class CreateAllMembers < ActiveRecord::Migration
  def change
    create_table :all_members do |t|
      t.datetime  :event

      t.timestamps
    end
  end
end
