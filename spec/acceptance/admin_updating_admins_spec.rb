require 'acceptance/acceptance_helper'

feature 'Updating admins', %q{
  In order to update admins in the system
  As an admin
  I want to update admins
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # And I have a admin to update
    @admin_to_update = FactoryGirl.create(:admin, :email => 'newadmin@foo.bar')
    
    # When I visit the update admin page
    visit 'admins/' + @admin_to_update.id.to_s + '/edit'
    
  end

  scenario 'Updating a new admin correctly' do

    # And I update the admin
    fill_in 'admin_email',                  :with => 'new@foobar.com'
    fill_in 'admin_password',               :with => 'apassword'
    fill_in 'admin_password_confirmation',  :with => 'apassword' 
    click_button 'Update admin'
    
    # Then I should not see an error message.
    expect(page).to have_no_selector('div.field_with_errors')
  end

  scenario 'Updating a new admin incorrectly' do

    # And I update the admin incorrectly
    # And I update the admin
    fill_in 'admin_email',                  :with => 'new@foobar.com'
    fill_in 'admin_password',               :with => 'apassword'
    fill_in 'admin_password_confirmation',  :with => 'bpassword' 
    click_button 'Update admin'
    
    # Then I should see an error message
    expect(page).to have_selector('div.field_with_errors')
  end

end