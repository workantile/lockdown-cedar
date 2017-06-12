require 'rails_helper'

describe Admin::DoorControllersController do
	before(:each) do
		@the_admin = FactoryGirl.create(:admin)
    sign_in @the_admin, scope: :admin
  end

  describe "GET index" do
  	before(:each) do
  		@door_controllers = FactoryGirl.create(:door_controller)
  		get :index
  	end

  	it "assigns to @door_controllers" do
  		expect(assigns(:door_controllers)).to eq([@door_controllers])
  	end

  	it "renders the index template" do
  		expect(response).to render_template('index')
  	end
  end

  describe "GET 'new'" do
    it "assigns to @door_controller" do
      get :new
      expect(assigns(:door_controller)).to be_kind_of(DoorController)
    end

    it "renders the 'new' template" do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe "POST create" do
    describe "success" do
      before(:each) do
        post(:create, :door_controller => FactoryGirl.attributes_for(:door_controller))
      end

      it "persists a new door controller with the parameters submitted" do
        expect(assigns(:door_controller)).to be_persisted
      end

      it "redirects to the index" do
        expect(response).to redirect_to(admin_door_controllers_url)
      end
    end

    describe "failure" do
      before(:each) do
        post(:create, :door_controller => FactoryGirl.attributes_for(:door_controller, :address => ''))
      end

      it "renders the new template again" do
        expect(response).to render_template('new')
      end

      it "does not persist a new door controller" do
        expect(assigns(:door_controller)).not_to be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      door_controller = FactoryGirl.create(:door_controller)
      get(:edit, :id => door_controller.id)
    end

    it 'assigns to @door_controller' do
      expect(assigns(:door_controller)).to be_kind_of(DoorController)
    end

    it "renders the 'edit' template" do
      expect(response).to render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
    	before(:each) do
      	door_controller = FactoryGirl.create(:door_controller)
    		put(:update, :id => door_controller.id, :door_controller => FactoryGirl.attributes_for(:door_controller))
    	end

      it "redirects to the index" do
        expect(response).to redirect_to(admin_door_controllers_url)
      end
    end

    describe 'failure' do
    	before(:each) do
    		door_controller = FactoryGirl.create(:door_controller)
    		put(:update, :id => door_controller.id, :door_controller => FactoryGirl.attributes_for(:door_controller, :address => ''))
    	end

    	it "renders the 'edit' template" do
    		expect(response).to render_template('edit')
    	end
    end
  end

  describe "DELETE 'destroy'" do
  	before(:each) do
  		door_controller = FactoryGirl.create(:door_controller)
  		delete(:destroy, :id => door_controller.id)
  	end

  	it "redirects to the index" do
  		expect(response).to redirect_to(admin_door_controllers_url)
  	end
  end

end
