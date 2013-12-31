require 'spec_helper'

describe Admin::AllMemberEventsController do
  before(:each) do
    sign_in :admin, FactoryGirl.create(:admin)
  end

  describe "GET index" do
    let!(:all_member_events) { FactoryGirl.create(:all_member_event) }

    before(:each) do
      get :index
    end

    it "assigns to @all_member_events" do
      expect(assigns(:all_member_events)).to eq([all_member_events])
    end

    it "renders the index template" do
      expect(response).to render_template('index')
    end
  end

  describe "GET 'new'" do
    it "assigns to @all_member_event" do
      get :new
      expect(assigns(:all_member_event)).to be_kind_of(AllMemberEvent)
    end 
  
    it "renders the 'new' template" do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe "POST create" do
    describe "success" do
      before(:each) do
        post(:create, :all_member_event => FactoryGirl.attributes_for(:all_member_event))
      end
    
      it "persists a new all member event with the parameters submitted" do
        expect(assigns(:all_member_event)).to be_persisted
      end
    
      it "redirects to the index" do
        expect(response).to redirect_to(admin_all_member_events_url)
      end
    end

    describe "failure" do
      before(:each) do
        post(:create, :all_member_event => FactoryGirl.attributes_for(:all_member_event, :name => ''))
      end

      it "renders the new template again" do
        response.should render_template('new')
      end
    
      it "does not persist a new all member event" do
        assigns(:all_member_event).should_not be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      get(:edit, :id => FactoryGirl.create(:all_member_event).id)
    end

    it 'assigns to @all_member_event' do
      assigns(:all_member_event).should be_kind_of(AllMemberEvent)
    end
  
    it "renders the 'edit' template" do
      response.should render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
      it "redirects to the index" do
        all_member_event = FactoryGirl.create(:all_member_event)
        put(:update, :id => all_member_event.id, :all_member_event => FactoryGirl.attributes_for(:all_member_event))
        response.should redirect_to(admin_all_member_events_url)
      end
    end

    describe 'failure' do
      it "renders the 'edit' template" do
        all_member_event = FactoryGirl.create(:all_member_event)
        put(:update, :id => all_member_event.id, :all_member_event => FactoryGirl.attributes_for(:all_member_event, :name => ''))
        response.should render_template('edit')
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "redirects to the index" do
      delete(:destroy, :id => FactoryGirl.create(:all_member_event).id)
      response.should redirect_to(admin_all_member_events_url)
    end
  end

end
