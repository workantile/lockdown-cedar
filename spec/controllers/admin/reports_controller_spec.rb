require 'spec_helper'

describe Admin::ReportsController do
	before(:each) do
		@the_admin = FactoryGirl.create(:admin)
		sign_in :admin, @the_admin
  end

  describe "GET 'index'" do
  	it "renders the index template" do
	  	get :index
	  	response.should render_template(:index)
  	end
  end

end
