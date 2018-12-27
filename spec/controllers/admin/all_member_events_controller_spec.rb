require 'rails_helper'

describe Admin::AllMemberEventsController do
  before(:each) do
    sign_in FactoryBot.create(:admin), scope: :admin
  end

  describe "GET index" do
    let!(:all_member_events) { FactoryBot.create(:all_member_event) }

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
        post(:create, :all_member_event => FactoryBot.attributes_for(:all_member_event))
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
        post(:create, :all_member_event => FactoryBot.attributes_for(:all_member_event, :name => ''))
      end

      it "renders the new template again" do
        expect(response).to render_template('new')
      end

      it "does not persist a new all member event" do
        expect(assigns(:all_member_event)).not_to be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      get(:edit, :id => FactoryBot.create(:all_member_event).id)
    end

    it 'assigns to @all_member_event' do
      expect(assigns(:all_member_event)).to be_kind_of(AllMemberEvent)
    end

    it "renders the 'edit' template" do
      expect(response).to render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
      it "redirects to the index" do
        all_member_event = FactoryBot.create(:all_member_event)
        put(:update, :id => all_member_event.id, :all_member_event => FactoryBot.attributes_for(:all_member_event))
        expect(response).to redirect_to(admin_all_member_events_url)
      end
    end

    describe 'failure' do
      it "renders the 'edit' template" do
        all_member_event = FactoryBot.create(:all_member_event)
        put(:update, :id => all_member_event.id, :all_member_event => FactoryBot.attributes_for(:all_member_event, :name => ''))
        expect(response).to render_template('edit')
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "redirects to the index" do
      delete(:destroy, :id => FactoryBot.create(:all_member_event).id)
      expect(response).to redirect_to(admin_all_member_events_url)
    end
  end

end
