require 'acceptance/acceptance_helper'

feature 'Member opens door', %q{
  In order use the space
  As a member
  I want to open the door
} do
  
  background do
    # Given the space has a door
    @door = FactoryGirl.create(:door)

    # Don't queue up the email so this test sees it.
    Delayed::Worker.delay_jobs = false
  end
  
  scenario 'A current affiliate member opens the door' do
    # Given I am a current member
    member = FactoryGirl.create(:affiliate_member)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door.address + "/" + member.rfid
    
    # Then the door should open.
    page.should have_content('OK')

    # And I should receive an email.
    last_email.to.should include(member.email)
  end

  scenario 'A former member opens the door' do
    # Given I am a former member
    member = FactoryGirl.create(:former_member)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door.address + "/" + member.rfid
    
    # Then the door should not open.
    page.should have_content('ERROR')
  end

  scenario 'A current member whose key has been disabled opens the door' do
    # Given I am a current member with a disabled key
    member = FactoryGirl.create(:former_member, :key_enabled => false)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door.address + "/" + member.rfid
    
    # Then the door should not open.
    page.should have_content('ERROR')
  end
end