require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.create(:full_member)
  end

  it { should respond_to :full_name }
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

  # it { should ensure_inclusion_of(:key_enabled).in_array([true, false]) }

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

  describe ".grant_access?" do
    before(:each) do
      @door = FactoryGirl.create(:door)
    end

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
        Member.grant_access?(@member.rfid, @door.address).should scenario[:desired_outcome] ? be_true : be_false
      end
    end

    it "should not grant access to a non-existant member" do
      @member.destroy
      Member.grant_access?(@member.rfid, @door.address).should be_false
    end

    it "should not grant access to a non-existant door" do
      Member.grant_access?(@member.rfid, 'bad door').should be_false
    end

    it "should log successful access attempts" do
      expect {
        Member.grant_access?(@member.rfid, @door.address)
      }.to change(AccessLog, :count).by(1)
    end

    it "should log denials" do
      pending "we need to log denials"
      @member.update_attributes(:member_type => 'former')
      expect {
        Member.grant_access?(@member.rfid, @door.address)
      }.to change(AccessLog, :count).by(1)
    end

    it "should not log unsuccessful access attempts" do
      @member.destroy
      expect {
        Member.grant_access?(@member.rfid, @door.address)
      }.to change(AccessLog, :count).by(0)
    end
  end

end
