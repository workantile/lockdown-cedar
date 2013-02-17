class CreateDoorController < ActiveRecord::Migration
  def change
    create_table :door_controllers do |t|
      t.string :address
      t.string :location
      t.string :success_response
      t.string :error_response

      t.timestamps
    end
  end
end
