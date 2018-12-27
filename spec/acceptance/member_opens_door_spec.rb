require 'acceptance/acceptance_helper'

feature 'Member opens door', %q{
  In order use the space
  As a member
  I want to open the door
} do

  background do
    # Given the space has a door
    @door_controller = FactoryBot.create(:door_controller)

    # Don't queue up the email so this test sees it.
    Delayed::Worker.delay_jobs = false
  end

  scenario 'A current affiliate member opens the door' do
    # Given I am a current member
    member = FactoryBot.create(:affiliate_member)

    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid

    # Then the door should open.
    expect(page).to have_content(@door_controller.success_response)

    # And I should receive an email.
    expect(last_email.to).to include(member.email)

    # When I open the door a second time today
    ActionMailer::Base.deliveries.clear
    visit '/access/' + @door_controller.address + "/" + member.rfid

    # I should not receive an email
    expect(last_email).to be_nil
  end

  scenario 'A former member opens the door' do
    # Given I am a former member
    member = FactoryBot.create(:former_member)

    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid

    # Then the door should not open.
    expect(page).to have_content(@door_controller.error_response)
  end

  scenario 'A current member whose key has been disabled opens the door' do
    # Given I am a current member with a disabled key
    member = FactoryBot.create(:former_member, :key_enabled => false)

    # When I put my rfid next to the reader
    visit '/access/' + @door_controller.address + "/" + member.rfid

    # Then the door should not open.
    expect(page).to have_content(@door_controller.error_response)
  end
end