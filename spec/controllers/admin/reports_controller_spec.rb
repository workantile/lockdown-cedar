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

  describe "POST 'export'" do
    def post_export
      post(:export, :start_date => '01/01/2013', :end_date => '01/31/2013')
    end

    it "calls the members export method" do
      AccessLog.should_receive(:export_to_csv).with(Date.new(2013,1,1)..Date.new(2013,1,31))
      post_export
    end

    it "renders the response as text" do
      expected_return = "'comma', separated', 'values'"
      AccessLog.should_receive(:export_to_csv).with(Date.new(2013,1,1)..Date.new(2013,1,31)) { expected_return }
      post_export
      response.body.should match(/#{expected_return}/)
    end
  end

end
