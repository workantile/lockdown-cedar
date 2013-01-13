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

    # And I have a member I want to bill
    anniversary_date = Date.new(2012, 1, 1)
    @member_to_invoice = FactoryGirl.create(:affiliate_member, :anniversary_date => anniversary_date)
    (Member::AFFILIATE_FREE_DAY_PASSES + 2).times { 
      |n| FactoryGirl.create(:log_success, 
                             :access_date => anniversary_date + n.day,
                             :member => @member_to_invoice)
    }

    # And it is the member's next billing period
    Timecop.travel(anniversary_date.next_month)

    # When I visit the member billing page
    visit billing_admin_members_path
    
  end
  
  scenario 'Billing a member' do
    # And I want to bill a member
    page.should have_content(@member_to_invoice.full_name)

    # And I click the "Mark as invoiced" button
    click_button('Mark')

    pending "get javascript testing to work"
  end

end
