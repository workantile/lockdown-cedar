class AddLastDateInvoicedToMember < ActiveRecord::Migration
  def change
    add_column :members, :last_date_invoiced, :date
  end
end
