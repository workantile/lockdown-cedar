require 'rails_helper'

describe Member do
  let!(:member)   { FactoryGirl.create(:full_member) }

  it { is_expected.to respond_to :full_name }
  it { is_expected.to respond_to :last_date_invoiced }
  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:member_type) }
  it { is_expected.to validate_presence_of(:billing_plan) }

  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:rfid).case_insensitive}

  it { is_expected.to validate_inclusion_of(:member_type).in_array(['current',
  																											 'former',
  																											 'courtesy key']) }

  it { is_expected.to validate_inclusion_of(:billing_plan).in_array(['full',
                                                         'full - no work',
                                                         'affiliate',
                                                         'student',
                                                         'supporter',
                                                         'none']) }

  it { is_expected.to have_many(:access_logs) }
  it { is_expected.to have_many(:pending_updates) }

  context "counting total, countable, free, and billable usage" do
    # usage: total days of access in a month
    # countable usage: total usage in a month that are not Sunday
    #   and not all-member events.
    # free usage: total countable usage up to Member::AFFILIATE_FREE_DAY_PASSES
    # billable usage: total countable usage - Member::AFFILIATE_FREE_DAY_PASSES,
    #   0 if negative.
    let!(:affiliate)  { FactoryGirl.create(:affiliate_member) }

    before(:each) do
      time_this_month = DateTime.new(2017, 6, 7, 10, 30, 0)
      time_last_month = DateTime.new(2017, 5, 3, 11, 0, 0)

      (0..7).each { |n|
        a_time = time_this_month + n.day
        another_time = time_last_month + n.day
        FactoryGirl.create(:log_success, member: affiliate, access_date_time: a_time)
        FactoryGirl.create(:log_success, member: affiliate, access_date_time: a_time + 30.minutes)
      }

      (0..6).each { |n|
        another_time = time_last_month + n.day
        FactoryGirl.create(:log_success, member: affiliate, access_date_time: another_time)
        FactoryGirl.create(:log_success, member: affiliate, access_date_time: another_time + 30.minutes)
      }

      FactoryGirl.create(:all_member_event, scheduled: DateTime.new(2017, 6, 7, 5, 0, 0))
      FactoryGirl.create(:all_member_event, scheduled: DateTime.new(2017, 5, 3, 5, 0, 0))

      Timecop.freeze(2017, 6, 30)
    end

    after(:each) do
      Timecop.return
    end

    context "usage in this month" do
      describe "#usage_this_month" do
        it "returns number of days user used the facility" do
          expect(affiliate.usage_this_month).to eq(8)
        end
      end

      describe "#countable_usage_this_month" do
        it "returns number of days user used the facility that are not Sundays or all member events" do
          expect(affiliate.countable_usage_this_month).to eq(6)
        end
      end

      describe "#free_usage_this_month" do
        it "returns countable usage up to the number of free day passes affiliates are allowed" do
          expect(affiliate.free_usage_this_month).to eq(Member::AFFILIATE_FREE_DAY_PASSES)
        end
      end

      describe "#billable_usage_this_month" do
        it "returns the countable usage over the number of free day passes affiliates are allowed" do
          expect(affiliate.billable_usage_this_month).to eq(2)
        end
      end

    end # end context usage in this month

    context "usage in last month" do
      describe "#usage_last_month" do
        it "returns number of days user used the facility" do
          expect(affiliate.usage_last_month).to eq(7)
        end
      end

      describe "#countable_usage_last_month" do
        it "returns number of days user used the facility that are not Sundays or all member events" do
          expect(affiliate.countable_usage_last_month).to eq(5)
        end
      end

      describe "#free_usage_last_month" do
        it "returns countable usage up to the number of free day passes affiliates are allowed" do
          expect(affiliate.free_usage_last_month).to eq(Member::AFFILIATE_FREE_DAY_PASSES)
        end
      end

      describe "#billable_usage_last_month" do
        it "returns the countable usage over the number of free day passes affiliates are allowed" do
          expect(affiliate.billable_usage_last_month).to eq(1)
        end
      end

    end # end context usage in last month

  end # end context counting total, countable, free, and billable usage

  describe ".check_member_type" do
    it "should set the termination date when a member leaves" do
      expect {
        member.update_attributes(:member_type => 'former')
      }.to change(member, :termination_date).from(nil).to(Date.today)
    end

    it "should change billing plan to 'none' when a member leaves" do
      expect {
        member.update_attributes(:member_type => 'former')
      }.to change(member, :billing_plan).from(member.billing_plan).to('none')
    end

    it "should not set the termination date or billing plan otherwise" do
      expect {
        member.update_attributes(:task => 'some task')
      }.not_to change(member, :termination_date)

      expect {
        member.update_attributes(:task => 'some task')
      }.not_to change(member, :billing_plan)
    end
  end

  describe ".send_usage_email?" do
    let!(:affiliate) { FactoryGirl.create(:affiliate_member)}

    it "indicates affiliate members should receive usage emails" do
      expect(affiliate.send_usage_email?).to be true
    end

    it "indicates full members should not receive usage emails" do
      expect(member.send_usage_email?).to be false
    end

    it "indicates that an email not be sent if one was already sent today" do
      affiliate.usage_email_sent = Timecop.freeze(Date.current).to_date
      expect(affiliate.send_usage_email?).to be false
    end

    it "indicates that an email be sent if one was sent before today" do
      affiliate.usage_email_sent = Timecop.freeze(Date.current).to_date - 1.day
      expect(affiliate.send_usage_email?).to be true
    end
  end

  describe ".delay_update" do
    let!(:affiliate)  { FactoryGirl.create(:affiliate_member) }
    let(:pending)     { affiliate.pending_updates.first }

    before(:each) do
      Delayed::Worker.delay_jobs = true  # make sure this fucking thing is always on for these examples
      Timecop.freeze(Date.new(2012,1,15))
      affiliate.delay_update(:member_type, "former")
    end

    it "should create a pending update object" do
      expect(pending).not_to be_nil
    end

    it "should create a delayed job object" do
      expect(Delayed::Job.exists?(pending.delayed_job_id)).to be_truthy
    end

    it "the delayed job should run at the beginning of next month" do
      run_at = affiliate.last_of_month + 1.day
      expect(Delayed::Job.find(pending.delayed_job_id).run_at.to_date).to eq(run_at)
    end
  end

  describe ".destroy_pending_updates" do
    let!(:affiliate)  { FactoryGirl.create(:affiliate_member) }
    let(:pending)     { affiliate.pending_updates.first }

    before(:each) do
      Delayed::Worker.delay_jobs = true  # make sure this fucking thing is always on for these examples
      Timecop.freeze(Date.new(2012,1,15))
      affiliate.delay_update(:member_type, "former")
      affiliate.destroy_pending_updates
    end

    it "should destroy pending update objects" do
      expect(affiliate.pending_updates.count).to eq(0)
    end

    it "should delete associated delayed jobs" do
      expect(Delayed::Job.exists?(pending.delayed_job_id)).to be_falsey
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
      expect(members.map(&:billing_plan)).to include("full", "affiliate")
    end

    it "should return type asked for" do
      member = Member.lookup_type_plan("former", "all").first
      expect(member.member_type).to eq("former")
    end

  end

  describe ".last_day_present" do
    it "returns the last day present" do
      yesterday = Date.today.prev_day
      Timecop.freeze(yesterday)
      FactoryGirl.create(:log_success, :member => member)
      Timecop.return
      FactoryGirl.create(:log_success, :member => member)
      expect(member.last_day_present).to eq(Date.today)
    end
  end

  describe ".last_day_present_formatted" do
    it "returns the last day present formatted for display" do
      yesterday = Date.today.prev_day
      Timecop.freeze(yesterday)
      FactoryGirl.create(:log_success, :member => member)
      Timecop.return
      FactoryGirl.create(:log_success, :member => member)
      expect(member.last_day_present_formatted).to eq(Date.today.strftime("%m/%d/%Y"))
    end
  end

  describe ".needs_invoicing?" do
    let(:affiliate_yes)   { FactoryGirl.create(:affiliate_member) }
    let(:affiliate_no)    { FactoryGirl.create(:affiliate_member) }
    let(:former)          { FactoryGirl.create(:former_member) }

    before(:each) do
      a_time = DateTime.new(2017, 5, 8, 11, 30, 0)

      (0..4).each { |n|
        FactoryGirl.create(:log_success, access_date_time: a_time + n.day, member: affiliate_yes)
        FactoryGirl.create(:log_success, access_date_time: a_time + n.day, member: former)
      }
      (0..3).each { |n|
        FactoryGirl.create(:log_success, access_date_time: a_time + n.day, member: affiliate_no)
      }

      Timecop.freeze(2017, 6, 1, 5, 0, 0)
    end

    after(:each) do
      Timecop.return
    end

    it "should say yes only to current affiliate members" do
      expect(member.needs_invoicing?).to be_falsey
      expect(affiliate_yes.needs_invoicing?).to be_truthy
      expect(former.needs_invoicing?).to be_falsey
    end

    it "should say yes only to members with excess uasge in the previous billing period" do
      expect(affiliate_yes.needs_invoicing?).to be_truthy
      expect(affiliate_no.needs_invoicing?).to be_falsey
    end

    it "should say yes only to members where the last_date_invoiced is blank or prior to the start of the current billing period" do
      affiliate_yes.update_attributes(last_date_invoiced: "")
      expect(affiliate_yes.needs_invoicing?).to be_truthy

      affiliate_yes.update_attributes(last_date_invoiced: affiliate_yes.last_month.first)
      expect(affiliate_yes.needs_invoicing?).to be_truthy

      affiliate_yes.update_attributes(last_date_invoiced: affiliate_yes.this_month.first)
      expect(affiliate_yes.needs_invoicing?).to be_falsey
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
        member.update_attributes(:member_type => scenario[:member_type],
                                  :key_enabled => scenario[:key_enabled])
        expect(member.access_enabled?).to scenario[:desired_outcome] ? be_truthy : be_falsey
      end
    end
  end

  describe ".members_to_invoice" do
    before(:each) do
      start_date = Date.new(2012, 1, 1)
      FactoryGirl.create(:affiliate_member)
      2.times do
        affiliate = FactoryGirl.create(:affiliate_member)
        (Member::AFFILIATE_FREE_DAY_PASSES + 2).times {
          |n| FactoryGirl.create(:log_success,
                                 access_date_time: start_date + n.day,
                                 member: affiliate)
        }
      end
      Timecop.freeze(start_date.next_month)
    end

    it "should return affiliate members with excess day pass usage in the previous billing period" do
      expect(Member.members_to_invoice.count).to eq(2)
    end
  end

  describe ".members_absent" do
    it "should return an array of members absent for a specified number of weeks or more" do
      absent_member_1 = FactoryGirl.create(:full_member)
      absent_member_2 = FactoryGirl.create(:full_member)
      previously = Date.today - 30.day

      Timecop.freeze(previously)
      FactoryGirl.create(:log_success,
                         :member => member)
      FactoryGirl.create(:log_success,
                         :member => absent_member_1)
      FactoryGirl.create(:log_success,
                         :member => absent_member_2)

      Timecop.return
      FactoryGirl.create(:log_success,
                         :member => member)

      expect(Member.members_absent(3)).to eq([absent_member_1, absent_member_2])
    end

    it "should not return suppoting members" do
      absent_member = FactoryGirl.create(:supporter_member)
      previously = Date.today - 30.day
      Timecop.freeze(previously)
      FactoryGirl.create(:log_success,
                         :member => member)
      FactoryGirl.create(:log_success,
                         :member => absent_member)
      Timecop.return
      expect(Member.members_absent(3)).to eq([member])
    end
  end

  describe ".find_by_key" do
    let(:rfid_number)       { "a1b2" }
    let!(:member_with_key)  { FactoryGirl.create(:full_member, rfid: rfid_number) }

    it "should return a member with a given rfid key" do
      expect(Member.find_by_key(rfid_number)).to eq(member_with_key)
    end

    it "should return a member with a given rfid key with a case-insensitive serch" do
      expect(Member.find_by_key(rfid_number.upcase)).to eq(member_with_key)
    end

    it "should return nil if the key does not belong to any member" do
      expect(Member.find_by_key("non-existent key")).to eq(nil)
    end
  end

  describe ".export_to_csv" do
    before(:each) do
      FactoryGirl.create(:full_member)
      FactoryGirl.create(:affiliate_member)
      FactoryGirl.create(:former_member)
    end

    it "should return a comma-separated string containing member types and plans specified" do
      expect(Member.export_to_csv('current', 'all')).to match(/,current/)
      expect(Member.export_to_csv('current', 'all')).to match(/,full/)
      expect(Member.export_to_csv('current', 'all')).to match(/,affiliate/)
    end
  end

end
