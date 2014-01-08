require 'acceptance/acceptance_helper'

feature 'Member opens door', %q{
  In order use the space
  As a member
  I want to open the door
} do
  
  background do
    # Given the space has a door
    @door_controller = FactoryGirl.create(:door_controller)

    # Don't queue up the email so this test sees it.
    Delayed::Worker.delay_jobs = false
  end
  
  scenario 'A current affiliate member opens the door' do
    # Given I am a current member
    member = FactoryGirl.create(:affiliate_member)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid
    
    # Then the door should open.
    page.should have_content(@door_controller.success_response)

    # And I should receive an email.
    last_email.to.should include(member.email)

    # When I open the door a second time today
    ActionMailer::Base.deliveries.clear
    visit '/access/' + @door_controller.address + "/" + member.rfid

    # I should not receive an email
    last_email.should be_nil
  end

  scenario 'A former member opens the door' do
    # Given I am a former member
    member = FactoryGirl.create(:former_member)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid
    
    # Then the door should not open.
    page.should have_content(@door_controller.error_response)
  end

  scenario 'A current member whose key has been disabled opens the door' do
    # Given I am a current member with a disabled key
    member = FactoryGirl.create(:former_member, :key_enabled => false)
    
    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid
    
    # Then the door should not open.
    page.should have_content(@door_controller.error_response)
  end
end