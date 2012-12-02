require 'spec_helper'

describe Admin::MembersController do
	before(:each) do
		@the_admin = FactoryGirl.create(:admin)
		sign_in :admin, @the_admin
  end

  describe "GET 'new'" do
    it "assigns to @member" do
      get :new
      assigns(:member).should be_kind_of(Member)
    end 
  
    it "renders the 'new' template" do
      get :new
      response.should render_template('new')
    end
  end

  describe "POST 'create'" do
    describe "success" do
      before(:each) do
        post(:create, :member => FactoryGirl.attributes_for(:full_member))
      end
    
      it "persists a new member with the parameters submitted" do
        assigns(:member).should be_persisted
      end
    
      it "redirects to the index" do
        response.should redirect_to(admin_members_url)
      end
    end
  
    describe "failure" do
      before(:each) do
        post(:create, :member => FactoryGirl.attributes_for(:full_member, :email => ""))
      end

      it "renders the new template again" do
        response.should render_template('new')
      end
    
      it "does not persist a new member" do
        assigns(:member).should_not be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      member = FactoryGirl.create(:full_member)
      get(:edit, :id => member.id)
    end

    it 'assigns to @member' do
      assigns(:member).should be_kind_of(Member)
    end
  
    it "renders the 'edit' template" do
      response.should render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
    	before(:each) do
    		member = FactoryGirl.create(:full_member)
    		put(:update, :id => member.id, :member => FactoryGirl.attributes_for(:full_member))
    	end

      it "redirects to the index" do
        response.should redirect_to(admin_members_url)
      end
    end

    describe 'failure' do
    	before(:each) do
    		member = FactoryGirl.create(:full_member)
    		put(:update, :id => member.id, :member => FactoryGirl.attributes_for(:full_member, :email => ''))
    	end

    	it "renders the 'edit' template" do
    		response.should render_template('edit')
    	end
    end
  end

  describe "DELETE 'destroy'" do
  	before(:each) do
  		member = FactoryGirl.create(:full_member)
  		delete(:destroy, :id => member.id)
  	end

  	it "redirects to the index" do
  		response.should redirect_to(admin_members_url)
  	end
  end
end
