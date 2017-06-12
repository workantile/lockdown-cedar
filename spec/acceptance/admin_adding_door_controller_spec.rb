require 'acceptance/acceptance_helper'

feature 'Adding door controllers', %q{
  In order to control access to the space
  As an admin
  I want to create door controllers
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # When I visit the new member page
    visit 'door_controllers/new'
    
  end
  
  scenario 'Creating a new door controller correctly' do
    fill_in 'door_controller_address',          :with => 'deadbeef10'
    fill_in 'door_controller_location',         :with => 'bank lobby'
    fill_in 'door_controller_success_response', :with => '<OK>'
    fill_in 'door_controller_error_response',   :with => '<ERROR>'
    click_button 'Create door controller'
    
    # Then I should not see an error message.
    expect(page).to have_no_selector('div.field_with_errors')
  end

  scenario 'Screwing up creating a new door controller' do
    fill_in 'door_controller_address',          :with => ''
    fill_in 'door_controller_location',         :with => 'bank lobby'
    fill_in 'door_controller_success_response', :with => '<OK>'
    fill_in 'door_controller_error_response',   :with => '<ERROR>'
    click_button 'Create door controller'
    
    # Then I should see an error message
    expect(page).to have_selector('div.field_with_errors')
  end
end