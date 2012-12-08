require 'acceptance/acceptance_helper'

feature 'Creating members', %q{
  In order to have members in the system
  As an admin
  I want to create members
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # When I visit the new member page
    visit 'members/new'
    
  end
  
  scenario 'Creating a new member correctly' do
    # And I create a new member correctly
    fill_in 'member_first_name',        :with => 'joe'
    fill_in 'member_last_name',         :with => 'blow'
    fill_in 'member_email',             :with => 'jblow@foobar.com'
    fill_in 'member_task',              :with => 'cruise director'
    fill_in 'member_pay_simple_customer_id', :with => 'some id'
    fill_in 'member_anniversary_date',  :with => Date.today.strftime("%m/%d/%Y")
    fill_in 'member_rfid',              :with => '1234'
    select 'current',                   :from => 'Member type'
    select 'full',                      :from => 'Billing plan'
    click_button 'Create member'
    
    # Then I should not see an error message.
    page.should have_no_selector('div.field_with_errors')
  end

  scenario 'Screwing up creating a new member' do
    # And I screw up creating a new member
    fill_in 'member_first_name',        :with => 'joe'
    fill_in 'member_last_name',         :with => 'blow'
    fill_in 'member_email',             :with => ''
    fill_in 'member_task',              :with => 'cruise director'
    fill_in 'member_anniversary_date',  :with => Date.today.strftime("%m/%d/%Y")
    fill_in 'member_rfid',              :with => '1234'
    select 'current',                   :from => 'Member type'
    select 'full',                      :from => 'Billing plan'
    click_button 'Create member'
    
    # Then I should see an error message
    page.should have_selector('div.field_with_errors')
  end
end