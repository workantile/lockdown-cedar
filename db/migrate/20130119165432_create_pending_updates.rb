class CreatePendingUpdates < ActiveRecord::Migration
  def change
    create_table :pending_updates do |t|
      t.string :description
      t.integer :delayed_job_id
      t.references :member

      t.timestamps
    end
  end
end
