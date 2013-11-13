require 'acceptance/acceptance_helper'

feature 'Find user by key', %q{
  In order to see what user belongs to a key
  As an admin
  I want to scan a key and find the user it belongs to
} do
  
  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)
    
    # And I have signed in
    sign_in_as @i_am_an_admin

    # And a member exists
    @member = FactoryGirl.create(:full_member, rfid: '1234')

    # When I visit the members page
    visit 'members'
    
  end

  scenario 'Find a member' do
    # And I read a key attached to an existing member
    fill_in 'rfid_key', :with => '1234'
    
    # And I click the 'find member' button
    click_button 'Find member'

    # Then I should see the member with the that key.
    page.should have_content(@member.rfid)
  end

end
