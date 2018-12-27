require 'rails_helper'

describe Admin::AdminsController do
	before(:each) do
		@the_admin = FactoryBot.create(:admin)
    sign_in @the_admin, scope: :admin
  end

  describe "GET 'new'" do
    it "assigns to @admin" do
      get :new
      expect(assigns(:admin)).to be_kind_of(Admin)
    end

    it "renders the 'new' template" do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe "POST 'create'" do
    describe "success" do
      before(:each) do
        post(:create, :admin => FactoryBot.attributes_for(:admin,
        																									 :email => "foo@foobar.com",
        																									 :password => "apassword",
        																									 :password_confirmation => "apassword"))
      end

      it "persists a new admin with the parameters submitted" do
        expect(assigns(:admin)).to be_persisted
      end

      it "redirects to the index" do
        expect(response).to redirect_to(admin_admins_url)
      end
    end

    describe "failure" do
      before(:each) do
        post(:create, :admin => FactoryBot.attributes_for(:admin,
        																									 :email => "foo@foobar.com",
        																									 :password => "apassword",
        																									 :password_confirmation => ""))
      end

      it "renders the new template again" do
        expect(response).to render_template('new')
      end

      it "does not persist a new admin" do
        expect(assigns(:admin)).not_to be_persisted
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      admin = FactoryBot.create(:other_admin)
      get(:edit, :id => admin.id)
    end

    it 'assigns to @admin' do
      expect(assigns(:admin)).to be_kind_of(Admin)
    end

    it "renders the 'edit' template" do
      expect(response).to render_template('edit')
    end
  end

  describe "PUT 'update'" do
    describe 'success' do
      before(:each) do
      	admin = FactoryBot.create(:other_admin)
        put(:update, :id => admin.id, :admin => {:email => admin.email,
        																				 :password => admin.password,
        																				 :password_confirmation => admin.password})
      end

      it "redirects to the index" do
        expect(response).to redirect_to(admin_admins_url)
      end
    end

    describe "failure" do
      before(:each) do
      	admin = FactoryBot.create(:other_admin)
        admin.password = ""
        put(:update, :id => admin.id, :admin => {:email => admin.email,
        																				 :password => admin.password,
        																				 :password_confirmation => admin.password})
      end

      it "renders the 'edit' template" do
        expect(response).to render_template('edit')
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "deleting an admin" do
      before(:each) do
        admin = FactoryBot.create(:other_admin)
        delete(:destroy, :id => admin.id)
      end

      it "redirects to the index" do
        expect(response).to redirect_to(admin_admins_url)
      end
    end
  end

end
