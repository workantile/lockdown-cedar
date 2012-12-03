class CreateDoors < ActiveRecord::Migration
  def change
    create_table :doors do |t|
      t.string :name
      t.string :address
      t.string :shared_secret

      t.timestamps
    end
  end
end
