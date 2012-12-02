module HelperMethods
  def sign_in_as(admin)
    visit '/admins/sign_in'
    fill_in 'Email', :with => admin.email
    fill_in 'Password', :with => admin.password
    click_button 'Sign in'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance