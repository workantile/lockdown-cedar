class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
    	t.string 	:first_name
    	t.string 	:last_name
    	t.string 	:email
    	t.string 	:rfid
    	t.string	:member_type
    	t.date 		:anniversary_date

      t.timestamps
    end
  end
end
