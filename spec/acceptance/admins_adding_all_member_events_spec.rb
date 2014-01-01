require 'acceptance/acceptance_helper'

feature 'Adding all members events', %q{
  In order to allow affiliates access to special events without using a day pass
  As an admin
  I want to create all member events
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # When I visit the new member page
    visit 'all_member_events/new'
    
  end
  
  scenario 'Creating an all member event' do
    fill_in 'Name',       :with => "Social Lunch"
    fill_in 'Scheduled',  :with => "1/10/2013 07:00 pm"
    click_button 'Create all members event'
    
    # Then I should not see an error message.
    page.should have_no_selector('div.field_with_errors')
  end

  scenario 'Screwing up creating an all member event' do
    fill_in 'Name',  :with => ''
    click_button 'Create all members event'
    
    
    # Then I should see an error message
    page.should have_selector('div.field_with_errors')
  end
end