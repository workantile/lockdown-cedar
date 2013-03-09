require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.create(:full_member)
  end

  it { should respond_to :full_name }
  it { should respond_to :last_date_invoiced }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:member_type) }
  it { should validate_presence_of(:billing_plan) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:rfid)}

  it { should ensure_inclusion_of(:member_type).in_array(['current',
  																											 'former',
  																											 'courtesy key']) }

  it { should ensure_inclusion_of(:billing_plan).in_array(['full',
                                                         'full - no work',
                                                         'affiliate',
                                                         'student',
                                                         'supporter',
                                                         'none']) }

  it { should have_many(:access_logs) }
  it { should have_many(:pending_updates) }

  describe ".current_billing_period" do
    before(:each) do
      @member.update_attributes(:anniversary_date => Date.new(2012, 2, 15))
    end

    it "should return the current billing period" do
      Timecop.freeze(Date.new(2012, 11, 10))
      expected_period = Date.new(2012,10,15)..Date.new(2012,11,14)
      @member.current_billing_period.should eq(expected_period)
    end

    it "should not be confused by month or year boundaries" do
      Timecop.freeze(Date.new(2013, 1, 10))
      expected_period = Date.new(2012,12,15)..Date.new(2013,1,14)
      @member.current_billing_period.should eq(expected_period)

      Timecop.freeze(Date.new(2013, 1, 16))
      expected_period = Date.new(2013,1,15)..Date.new(2013,2,14)
      @member.current_billing_period.should eq(expected_period)
    end
  end

  describe ".previous_billing_period" do
    before(:each) do
      @member.update_attributes(:anniversary_date => Date.new(2012, 2, 15))
    end

    it "should return the previous billing period" do
      Timecop.freeze(Date.new(2012, 11, 10))
      expected_period = Date.new(2012,9,15)..Date.new(2012,10,14)
      @member.previous_billing_period.should eq(expected_period)
    end

    it "should not be confused by month or year boundaries" do
      Timecop.freeze(Date.new(2013, 2, 10))
      expected_period = Date.new(2012,12,15)..Date.new(2013,1,14)
      @member.previous_billing_period.should eq(expected_period)

      Timecop.freeze(Date.new(2013, 2, 16))
      expected_period = Date.new(2013,1,15)..Date.new(2013,2,14)
      @member.previous_billing_period.should eq(expected_period)
    end
  end

  describe ".usage_this_billing_period" do
    before(:each) do
      @member.update_attributes(:anniversary_date => Date.new(2012, 2, 15))
      2.times { FactoryGirl.create(:log_success, 
                                   :access_date => Date.new(2012, 11, 18),
                                   :member => @member)}
      1.upto(3) { |i| FactoryGirl.create(:log_success, 
                                         :access_date => Date.new(2012, 11, 18) + i.day,
                                         :member => @member) }
    end

    it "should count multipla access on 1 day as 1 day's usage" do
      Timecop.freeze(Date.new(2012, 11, 30))
      @member.usage_this_billing_period.should eq(4)
    end

    it "should not be confused by boundary conditions" do
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,11,15), :member => @member)
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,12,14), :member => @member)
      Timecop.freeze(Date.new(2012,12,14))
      @member.usage_this_billing_period.should eq(6)
    end

    it "should not count usage from the previous billing period" do
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,10,14), :member => @member)
      Timecop.freeze(Date.new(2012,11,30))
      @member.usage_this_billing_period.should eq(4)
    end
  end

  describe ".usage_this_month" do
    before(:each) do
      @this_is_now = Timecop.freeze(Date.new(2012, 11, 15))
      2.times { FactoryGirl.create(:log_success, :access_date => @this_is_now, :member => @member)}
      1.upto(3) { |i| FactoryGirl.create(:log_success, 
                                         :access_date => @this_is_now + i.day,
                                         :member => @member) }
    end

    it "should count multiple accesses on 1 day as 1 day's usage" do
      @member.usage_this_month.should eq(4)
    end

    it "should not count usage from last month" do
      FactoryGirl.create(:log_success,
                         :access_date => @this_is_now.prev_month,
                         :member => @member)
      @member.usage_this_month.should eq(4)
    end

    it "should not count usage belonging to another member" do
      @member2 = FactoryGirl.create(:affiliate_member)
      FactoryGirl.create(:log_success,
                         :access_date => @this_is_now,
                         :member => @member2)
      @member.usage_this_month.should eq(4)
      @member2.usage_this_month.should eq(1)
    end
  end

  describe ".usage_previous_billing_period" do
    before(:each) do
      @member.update_attributes(:anniversary_date => Date.new(2012, 2, 15))
      2.times { FactoryGirl.create(:log_success, 
                                   :access_date => Date.new(2012, 11, 18),
                                   :member => @member)}
      1.upto(3) { |i| FactoryGirl.create(:log_success, 
                                         :access_date => Date.new(2012, 11, 18) + i.day,
                                         :member => @member) }
    end

    it "should count multipla access on 1 day as 1 day's usage" do
      Timecop.freeze(Date.new(2012, 12, 30))
      @member.usage_previous_billing_period.should eq(4)
    end

    it "should not be confused by boundary conditions" do
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,11,15), :member => @member)
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,12,14), :member => @member)
      Timecop.freeze(Date.new(2013,01,14))
      @member.usage_previous_billing_period.should eq(6)
    end

    it "should not count usage from the previous billing period" do
      FactoryGirl.create(:log_success, :access_date => Date.new(2012,10,14), :member => @member)
      Timecop.freeze(Date.new(2012,12,30))
      @member.usage_previous_billing_period.should eq(4)
    end
  end

  describe ".check_member_type" do
    it "should set the termination date when a member leaves" do
      expect {
        @member.update_attributes(:member_type => 'former')
      }.to change(@member, :termination_date).from(nil).to(Date.today)
    end

    it "should change billing plan to 'none' when a member leaves" do
      expect {
        @member.update_attributes(:member_type => 'former')
      }.to change(@member, :billing_plan).from(@member.billing_plan).to('none')
    end

    it "should not set the termination date or billing plan otherwise" do
      expect {
        @member.update_attributes(:task => 'some task')
      }.not_to change(@member, :termination_date)

      expect {
        @member.update_attributes(:task => 'some task')
      }.not_to change(@member, :billing_plan)
    end
  end

  describe ".billing_period_begins" do
    it "should return the day of the month a member's billing period begins" do
      @member.anniversary_date = Date.new(2012,5,6)
      @member.billing_period_begins.should include '6'
    end
  end

  describe ".send_usage_email" do
    before(:each) do
      Delayed::Worker.delay_jobs = false
    end
    after(:each) do
      Delayed::Worker.delay_jobs = true
    end      
    
    it "should send an email to affiliate members" do
      @affiliate = FactoryGirl.create(:affiliate_member)
      @affiliate.send_usage_email
      last_email.to.should include(@affiliate.email)
    end

    it "should not send an email to a full member" do
      @member.send_usage_email
      last_email.should be_nil
    end

    it "should not send more than one email in one day to a member" do
      @affiliate = FactoryGirl.create(:affiliate_member)
      now = Timecop.freeze(Date.today)
      @affiliate.send_usage_email
      @affiliate.reload
      @affiliate.send_usage_email
      all_emails.count.should eq(1)

      Timecop.freeze(now + 1.day)
      @affiliate.send_usage_email
      @affiliate.reload
      @affiliate.send_usage_email
      all_emails.count.should eq(2)
    end

    it "should send a free day pass email if period-to-date usage is <= affilate free day passes" do
      start_date = Timecop.freeze(Date.new(2012,1,1))

      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => start_date)
      Member::AFFILIATE_FREE_DAY_PASSES.times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => start_date + n.day,
                               :member => @affiliate)
      }
      
      MemberEmail.should_receive(:free_day_pass_use).with(@affiliate).and_return(double("mailer", :deliver => true))
      @affiliate.send_usage_email
    end

    it "should send a billable day pass email if period-to-date usage is > affilate free day passes" do
      start_date = Timecop.freeze(Date.new(2012,1,1))

      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => start_date)
      (Member::AFFILIATE_FREE_DAY_PASSES + 1).times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => start_date + n.day,
                               :member => @affiliate)
      }
      
      MemberEmail.should_receive(:billable_day_pass_use).with(@affiliate).and_return(double("mailer", :deliver => true))
      @affiliate.send_usage_email
    end

  end

  describe ".delay_update" do
    before(:each) do
      Delayed::Worker.delay_jobs = true  # make sure this fucking thing is always on for these examples
      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => Date.new(2012,1,1))
      Timecop.freeze(Date.new(2012,1,15))  
      @affiliate.delay_update(:member_type, "former")
      @pending = @affiliate.pending_updates.first
    end

    it "should create a pending update object" do
      @pending.should_not be_nil
    end

    it "should create a delayed job object" do
      Delayed::Job.exists?(@pending.delayed_job_id).should be_true
    end

    it "the delayed job should run at the beginning of the next billing period" do
      run_at = @affiliate.current_billing_period.last + 1.day
      Delayed::Job.find(@pending.delayed_job_id).run_at.to_date.should eq(run_at)
    end
  end

  describe ".destroy_pending_updates" do
    before(:each) do
      Delayed::Worker.delay_jobs = true  # make sure this fucking thing is always on for these examples
      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => Date.new(2012,1,1))
      Timecop.freeze(Date.new(2012,1,15))  
      @affiliate.delay_update(:member_type, "former")
      @pending = @affiliate.pending_updates.first
      @affiliate.destroy_pending_updates
    end

    it "should destroy pending update objects" do
      @affiliate.pending_updates.count.should eq(0)
    end

    it "should delete associated delayed jobs" do
      Delayed::Job.exists?(@pending.delayed_job_id).should be_false
    end
  end
  
  describe ".billable_days_this_billing_period" do
    it "should return 0 if the member has not exceeded use of all free day passes" do
      start_date = Timecop.freeze(Date.new(2012,1,1)).to_date

      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => start_date)
      Member::AFFILIATE_FREE_DAY_PASSES.times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => start_date + n.day,
                               :member => @affiliate)
      }

      @affiliate.billable_days_this_billing_period.should eq(0)
    end

    it "should return the difference between the total day passes used and allowed number" do
      start_date = Timecop.freeze(Date.new(2012,1,1)).to_date

      @affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => start_date)
      (Member::AFFILIATE_FREE_DAY_PASSES + 2).times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => start_date + n.day,
                               :member => @affiliate)
      }

      @affiliate.billable_days_this_billing_period.should eq(2)
    end
  end

  describe ".lookup_type_plan" do
    before(:each) do
      FactoryGirl.create(:full_member)
      FactoryGirl.create(:affiliate_member)
      FactoryGirl.create(:former_member)
    end

    it "should return plan asked for" do
      members = Member.lookup_type_plan("current", "all")
      members.map(&:billing_plan).should include("full", "affiliate")
    end

    it "should return type asked for" do
      member = Member.lookup_type_plan("former", "all").first
      member.member_type.should eq("former")
    end

  end

  describe ".needs_invoicing?" do
    before(:each) do
      @anniversary_date = Date.new(2012, 1, 1)
      @affiliate_yes = FactoryGirl.create(:affiliate_member, :anniversary_date => @anniversary_date)
      (Member::AFFILIATE_FREE_DAY_PASSES + 2).times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => @anniversary_date + n.day,
                               :member => @affiliate_yes)
      }
      @affiliate_no = FactoryGirl.create(:affiliate_member, :anniversary_date => @anniversary_date)
      (Member::AFFILIATE_FREE_DAY_PASSES).times { 
        |n| FactoryGirl.create(:log_success, 
                               :access_date => @anniversary_date + n.day,
                               :member => @affiliate_no)
      }
      @former = FactoryGirl.create(:former_member, :anniversary_date => @anniversary_date)
      Timecop.freeze(@anniversary_date.next_month)
    end

    it "should say yes only to current affiliate members" do
      @member.needs_invoicing?.should be_false
      @affiliate_yes.needs_invoicing?.should be_true
      @former.needs_invoicing?.should be_false
    end

    it "should say yes only to members with excess uasge in the previous billing period" do
      @affiliate_yes.needs_invoicing?.should be_true
      @affiliate_no.needs_invoicing?.should be_false
    end

    it "should say yes only to members where the last_date_invoiced is blank or prior to the start of the current billing period" do
      @affiliate_yes.update_attributes(:last_date_invoiced => "")
      @affiliate_yes.needs_invoicing?.should be_true

      @affiliate_yes.update_attributes(:last_date_invoiced => @affiliate_yes.current_billing_period.first.prev_month)
      @affiliate_yes.needs_invoicing?.should be_true

      @affiliate_yes.update_attributes(:last_date_invoiced => @affiliate_yes.current_billing_period.first)
      @affiliate_yes.needs_invoicing?.should be_false
    end
  end

  describe ".access_enabled?" do
    scenarios = [{:member_type => 'current', :key_enabled => true, :desired_outcome => true},
                 {:member_type => 'current', :key_enabled => false, :desired_outcome => false},
                 {:member_type => 'former', :key_enabled => true, :desired_outcome => false},
                 {:member_type => 'former', :key_enabled => false, :desired_outcome => false},
                 {:member_type => 'courtesy key', :key_enabled => true, :desired_outcome => true},
                 {:member_type => 'courtesy key', :key_enabled => false, :desired_outcome => false}]

    scenarios.collect do |scenario|
      it "#{scenario[:desired_outcome] ? 'should' : 'should not'} grant access to a 
          #{scenario[:member_type]} member when their key is 
          #{scenario[:key_enabled] ? 'enabled' : 'disabled'}" do
        @member.update_attributes(:member_type => scenario[:member_type], 
                                  :key_enabled => scenario[:key_enabled])
        @member.access_enabled?.should scenario[:desired_outcome] ? be_true : be_false
      end
    end
  end

  describe ".members_to_invoice" do
    before(:each) do
      anniversary_date = Date.new(2012, 1, 1)
      FactoryGirl.create(:affiliate_member, :anniversary_date => anniversary_date)
      2.times do 
        affiliate = FactoryGirl.create(:affiliate_member, :anniversary_date => anniversary_date)
        (Member::AFFILIATE_FREE_DAY_PASSES + 2).times { 
          |n| FactoryGirl.create(:log_success, 
                                 :access_date => anniversary_date + n.day,
                                 :member => affiliate)
        }
      end
      Timecop.freeze(anniversary_date.next_month)
    end

    it "should return affiliate members with excess day pass usage in the previous billing period" do
      Member.members_to_invoice.count.should eq(2)
    end
  end

  describe ".export_to_csv" do 
    before(:each) do
      FactoryGirl.create(:full_member)
      FactoryGirl.create(:affiliate_member)
      FactoryGirl.create(:former_member)
    end

    it "should return a comma-separated string containing member types and plans specified" do
      Member.export_to_csv('current', 'all').should match(/,current/)
      Member.export_to_csv('current', 'all').should match(/,full/)
      Member.export_to_csv('current', 'all').should match(/,affiliate/)
    end
  end

end
