class AddFieldsToMembers < ActiveRecord::Migration
  def change
  	add_column :members, :billing_plan, :string
  	add_column :members, :key_enabled, :boolean, :default => true
  	add_column :members, :task, :string
  	add_column :members, :pay_simple_customer_id, :string
  	add_column :members, :termination_date, :date
  end
end
