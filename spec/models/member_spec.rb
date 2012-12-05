require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.create(:full_member)
    @member.save
  end

  it { should respond_to :full_name }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:member_type) }
  it { should validate_presence_of(:rfid) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:rfid)}

  it { should ensure_inclusion_of(:member_type).in_array(['full',
  																											 'full - no work',
  																											 'affiliate',
  																											 'student',
  																											 'non-member']) }

  describe ".grant_access?" do
    it "should grant access to an existing member" do
      Member.grant_access?(@member.rfid, FactoryGirl.create(:door).address).should be_true
    end

    it "should not grant access to a non-existant member" do
      @member.destroy
      Member.grant_access?(@member.rfid, FactoryGirl.create(:door).address).should be_false
    end

    it "should not grant access to a non-existant door" do
      Member.grant_access?(@member.rfid, 'bad door').should be_false
    end

    it "should log successful access attempts" do
      expect {
        Member.grant_access?(@member.rfid, FactoryGirl.create(:door).address)
      }.to change(AccessLog, :count).by(1)
    end

    it "should log unsuccessful access attempts" do
      @member.destroy
      expect {
        Member.grant_access?(@member.rfid, FactoryGirl.create(:door).address)
      }.to change(AccessLog, :count).by(1)
    end
  end

end
