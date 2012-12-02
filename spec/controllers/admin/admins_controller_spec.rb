require 'spec_helper'

describe Admin::AdminsController do
	before(:each) do
		@the_admin = FactoryGirl.create(:admin)
		sign_in :admin, @the_admin
  end

  describe "GET 'new'" do
    it "assigns to @admin" do
      get :new
      assigns(:admin).should be_kind_of(Admin)
    end 
  
    it "renders the 'new' template" do
      get :new
      response.should render_template('new')
    end
  end

  describe "POST 'create'" do
    describe "success" do
      before(:each) do
        post(:create, :admin => FactoryGirl.attributes_for(:admin, 
        																									 :email => "foo@foobar.com", 
        																									 :password => "apassword",
        																									 :password_confirmation => "apassword"))
      end
    
      it "persists a new admin with the parameters submitted" do
        assigns(:admin).should be_persisted
      end
    
      it "redirects to the index" do
        response.should redirect_to(admin_admins_url)
      end
    end
  
    describe "failure" do
      before(:each) do
        post(:create, :admin => FactoryGirl.attributes_for(:admin, 
        																									 :email => "foo@foobar.com", 
        																									 :password => "apassword",
        																									 :password_confirmation => ""))
      end

      it "renders the new template again" do
        response.should render_template('new')
      end
    
      it "does not persist a new admin" do
        assigns(:admin).should_not be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      admin = FactoryGirl.create(:other_admin)
      get(:edit, :id => admin.id)
    end

    it 'assigns to @admin' do
      assigns(:admin).should be_kind_of(Admin)
    end
  
    it "renders the 'edit' template" do
      response.should render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
      before(:each) do
      	admin = FactoryGirl.create(:other_admin)
        put(:update, :id => admin.id, :admin => {:email => admin.email,
        																				 :password => admin.password,
        																				 :password_confirmation => admin.password})
      end
    
      it "redirects to the index" do
        response.should redirect_to(admin_admins_url)
      end
    end
  
    describe "failure" do
      before(:each) do
      	admin = FactoryGirl.create(:other_admin)
        admin.password = ""
        put(:update, :id => admin.id, :admin => {:email => admin.email,
        																				 :password => admin.password,
        																				 :password_confirmation => admin.password})
      end

      it "renders the 'edit' template" do
        response.should render_template('edit')
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "deleting an admin" do
      before(:each) do
        admin = FactoryGirl.create(:other_admin)
        delete(:destroy, :id => admin.id)
      end

      it "redirects to the index" do
        response.should redirect_to(admin_admins_url)
      end
    end
  end

end
