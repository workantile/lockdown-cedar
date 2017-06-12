require 'acceptance/acceptance_helper'

feature 'Creating admins', %q{
  In order to have admins in the system
  As an admin
  I want to create admins
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # When I visit the new admin page
    visit 'admins/new'
    
  end
  
  scenario 'Creating a new admin correctly' do
    # And I create a new admin correctly
    fill_in 'admin_email',                  :with => 'jblow@foobar.com'
    fill_in 'admin_password',               :with => 'badpassword'
    fill_in 'admin_password_confirmation',  :with => 'badpassword'
    click_button 'Create admin'
    
    # Then I should not see an error message.
    expect(page).to have_no_selector('div.field_with_errors')
  end

  scenario 'Screwing up creating a new admin' do
    # And I screw up creating a new admin
    fill_in 'admin_email',                  :with => 'jblow@foobar.com'
    fill_in 'admin_password',               :with => 'badpassword'
    fill_in 'admin_password_confirmation',  :with => ''
    click_button 'Create admin'
    
    # Then I should see an error message
    expect(page).to have_selector('div.field_with_errors')
  end
end