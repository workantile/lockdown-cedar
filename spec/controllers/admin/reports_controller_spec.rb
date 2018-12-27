require 'rails_helper'

describe Admin::ReportsController do

  context "unauthorized access" do
    it "renders the sign_in template" do
      get :index
      expect(response).to redirect_to(new_admin_session_url)
    end
  end

  context "authorized access" do
  	before(:each) do
  		@the_admin = FactoryBot.create(:admin)
  		sign_in @the_admin, scope: :admin
    end

    describe "GET 'index'" do
    	it "renders the index template" do
  	  	get :index
  	  	expect(response).to render_template(:index)
    	end
    end

    describe "POST 'export'" do
      def post_export
        post(:export, :start_date => '01/01/2013', :end_date => '01/31/2013')
      end

      it "calls the members export method" do
        expect(AccessLog).to receive(:export_to_csv).with(Date.new(2013,1,1)..Date.new(2013,1,31))
        post_export
      end

      it "renders the response as text" do
        expected_return = "'comma', separated', 'values'"
        expect(AccessLog).to receive(:export_to_csv).with(Date.new(2013,1,1)..Date.new(2013,1,31)) { expected_return }
        post_export
        expect(response.body).to match(/#{expected_return}/)
      end
    end
  end

end
