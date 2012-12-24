class AddUsageEmailSentToMember < ActiveRecord::Migration
  def change
    add_column :members, :usage_email_sent, :date
  end
end
