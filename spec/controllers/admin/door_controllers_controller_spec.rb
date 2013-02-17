require 'spec_helper'

describe Admin::DoorControllersController do
	before(:each) do
		@the_admin = FactoryGirl.create(:admin)
		sign_in :admin, @the_admin
  end

  describe "GET index" do
  	before(:each) do
  		@door_controllers = FactoryGirl.create(:door_controller)
  		get :index
  	end

  	it "assigns to @door_controllers" do
  		assigns(:door_controllers).should eq([@door_controllers])
  	end

  	it "renders the index template" do
  		response.should render_template('index')
  	end
  end

  describe "GET 'new'" do
    it "assigns to @door_controller" do
      get :new
      assigns(:door_controller).should be_kind_of(DoorController)
    end 
  
    it "renders the 'new' template" do
      get :new
      response.should render_template('new')
    end
  end

  describe "POST create" do
    describe "success" do
      before(:each) do
        post(:create, :door_controller => FactoryGirl.attributes_for(:door_controller))
      end
    
      it "persists a new door controller with the parameters submitted" do
        assigns(:door_controller).should be_persisted
      end
    
      it "redirects to the index" do
        response.should redirect_to(admin_door_controllers_url)
      end
    end

    describe "failure" do
      before(:each) do
        post(:create, :door_controller => FactoryGirl.attributes_for(:door_controller, :address => ''))
      end

      it "renders the new template again" do
        response.should render_template('new')
      end
    
      it "does not persist a new door controller" do
        assigns(:door_controller).should_not be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      door_controller = FactoryGirl.create(:door_controller)
      get(:edit, :id => door_controller.id)
    end

    it 'assigns to @door_controller' do
      assigns(:door_controller).should be_kind_of(DoorController)
    end
  
    it "renders the 'edit' template" do
      response.should render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
    	before(:each) do
      	door_controller = FactoryGirl.create(:door_controller)
    		put(:update, :id => door_controller.id, :door_controller => FactoryGirl.attributes_for(:door_controller))
    	end

      it "redirects to the index" do
        response.should redirect_to(admin_door_controllers_url)
      end
    end

    describe 'failure' do
    	before(:each) do
    		door_controller = FactoryGirl.create(:door_controller)
    		put(:update, :id => door_controller.id, :door_controller => FactoryGirl.attributes_for(:door_controller, :address => ''))
    	end

    	it "renders the 'edit' template" do
    		response.should render_template('edit')
    	end
    end
  end

  describe "DELETE 'destroy'" do
  	before(:each) do
  		door_controller = FactoryGirl.create(:door_controller)
  		delete(:destroy, :id => door_controller.id)
  	end

  	it "redirects to the index" do
  		response.should redirect_to(admin_door_controllers_url)
  	end
  end

end
