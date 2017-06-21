require 'acceptance/acceptance_helper'

feature 'Billing members', %q{
  In order to invoice members for use of the space
  As an admin
  I want to invoice members
} do

  background do
    # Given I am an admin
    @i_am_an_admin = FactoryGirl.create(:admin)

    # And I have signed in
    sign_in_as @i_am_an_admin

    # And I have an affiliate member with 2 billable days and 1 non-billable day
    start_date = Date.new(2012, 1, 1)
    last_access = start_date
    @member_to_invoice = FactoryGirl.create(:affiliate_member)
    (Member::AFFILIATE_FREE_DAY_PASSES + 2).times do |n|
      last_access = start_date + n.day
      FactoryGirl.create( :log_success,
                          access_date_time: last_access,
                          member: @member_to_invoice )
    end

    FactoryGirl.create(:log_success,
                        access_date_time: last_access + 1.day,
                        member: @member_to_invoice)

    # And I want to look at the member's last month's activity
    Timecop.travel(start_date.next_month)

    # When I visit the member billing page
    visit billing_admin_members_path

  end

  scenario 'Shows number of billable days' do
    # I should see the number of billable days
    expect(find('.billable-days')).to have_content('2')
  end

  scenario 'Billing a member' do
    # And I want to bill a member
    expect(page).to have_content(@member_to_invoice.full_name)

    # And I click the "Mark as invoiced" button
    click_button('Mark')

  end

end
