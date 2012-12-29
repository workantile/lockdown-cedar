class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :category
      t.string :item
      t.integer :count
      t.date :snapshot_date

      t.timestamps
    end
  end
end
