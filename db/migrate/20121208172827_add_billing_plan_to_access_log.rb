class AddBillingPlanToAccessLog < ActiveRecord::Migration
  def change
  	add_column :access_logs, :billing_plan, :string
  end
end
