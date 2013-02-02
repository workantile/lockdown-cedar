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
        post(:create, :member => FactoryGirl.attributes_for(:full_member, :anniversary_date => "12/01/2012"))
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
        post(:create, :member => FactoryGirl.attributes_for(:full_member, :email => "", :anniversary_date => "12/01/2012"))
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
      pending_update = FactoryGirl.create(:pending_update, :member => member)
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
    		put(:update, :id => member.id, :member => FactoryGirl.attributes_for(:full_member, :anniversary_date => "12/01/2012"))
    	end

      it "redirects to the index" do
        response.should redirect_to(admin_members_url)
      end
    end

    describe 'failure' do
    	before(:each) do
    		member = FactoryGirl.create(:full_member)
    		put(:update, :id => member.id, :member => FactoryGirl.attributes_for(:full_member, :email => '', :anniversary_date => "12/01/2012"))
    	end

    	it "renders the 'edit' template" do
    		response.should render_template('edit')
    	end
    end

    describe 'update member type immediately' do
      it "should not create a pending update object" do
        member = FactoryGirl.create(:full_member)
        member_hash = FactoryGirl.attributes_for(:former_member, :anniversary_date => "12/01/2012")
        put(:update, :id => member.id, :member => member_hash, :member_type_timing => 'immediately')
        PendingUpdate.count.should eq(0)
      end
    end

    describe 'update member type at end of billing period' do
      before(:each) do
        Delayed::Worker.delay_jobs = true
        @member = FactoryGirl.create(:full_member)
        @member_hash = FactoryGirl.attributes_for(:former_member, :anniversary_date => "12/01/2012")
      end

      it "should invoke the delay update method" do
        Member.any_instance.should_receive(:delay_update)
        put(:update, :id => @member.id, :member => @member_hash, :member_type_timing => 'end_billing_period')
      end

      it "should not change the currenr value of member type" do
        put(:update, :id => @member.id, :member => @member_hash, :member_type_timing => 'end_billing_period')
        @member.reload
        @member.member_type.should eq('current')
      end
    end

    describe 'update billing plan immediately' do
      it "should not create a pending update object" do
        member = FactoryGirl.create(:full_member)
        member_hash = FactoryGirl.attributes_for(:affiliate_member, :anniversary_date => "12/01/2012")
        put(:update, :id => member.id, :member => member_hash, :billing_plan_timing => 'immediately')
        PendingUpdate.count.should eq(0)
      end
    end

    describe 'update billing plan at end of billing period' do
      before(:each) do
        Delayed::Worker.delay_jobs = true
        @member = FactoryGirl.create(:full_member)
        @member_hash = FactoryGirl.attributes_for(:affiliate_member, :anniversary_date => "12/01/2012")
      end

      it "should invoke the delay update method" do
        Member.any_instance.should_receive(:delay_update)
        put(:update, :id => @member.id, :member => @member_hash, :billing_plan_timing => 'end_billing_period')
      end

      it "should not change the current value of billing plan" do
        put(:update, :id => @member.id, :member => @member_hash, :billing_plan_timing => 'end_billing_period')
        @member.reload
        @member.billing_plan.should eq('full')
      end
    end
  end

  describe "DELETE pending updates" do
    before(:each) do
      @member = FactoryGirl.create(:full_member)
    end

    it "assigns to @member" do
      delete :destroy_delayed_updates, :id => @member.id
      assigns(:member).should be_kind_of(Member)
    end

    it "invokes the destroy pending update method" do
      Member.any_instance.should_receive(:destroy_pending_updates)
      delete :destroy_delayed_updates, :id => @member.id
    end

    it "redirect to the index" do
      delete :destroy_delayed_updates, :id => @member.id
      response.should redirect_to(admin_members_url)
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

  describe "POST 'export'" do
    it "calls the members export method" do
    end

    it "renders the response as text" do
    end

    it "redirects to the index" do
    end
  end

  describe "GET 'billing'" do
    before(:each) do
      anniversary_date = Date.new(2012, 1, 1)
      2.times {
        affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => anniversary_date)
        (Member::AFFILIATE_FREE_DAY_PASSES + 2).times { 
          |n| FactoryGirl.create(:log_success, 
                                 :access_date => anniversary_date + n.day,
                                 :member => affiliate)
        }
      }
      get :billing
      Timecop.freeze(anniversary_date.next_month)
    end

    it "assigns to members" do
      assigns(:members).should be_kind_of(Array)
    end

    it "renders the 'billing' template" do
      response.should render_template('billing')
    end
  end

  describe "PUT 'invoiced'" do
    it "updates the member" do
      affiliate = FactoryGirl.create(:affiliate_member)
      xhr(:put, :invoiced, :id => affiliate.id)
    end
  end

end
