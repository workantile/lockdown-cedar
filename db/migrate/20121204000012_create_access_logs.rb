class CreateAccessLogs < ActiveRecord::Migration
  def change
    create_table :access_logs do |t|
      t.date :access_date
      t.boolean :access_granted
      t.string :msg
      t.references :member
      t.references :door

      t.timestamps
    end
  end
end
