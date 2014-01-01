require 'spec_helper'

describe AllMemberEvent do
  let!(:all_member_event)  { FactoryGirl.create(:all_member_event)}

  it { should respond_to :name }
  it { should respond_to :scheduled }

  it { should validate_presence_of :name }
  it { should validate_presence_of :scheduled }

  describe ".event_happening?" do
    it "returns true if the current time is during an all day event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 12:00 am')
      Timecop.freeze(DateTime.new(2013, 1, 10, 13, 0))
      expect(AllMemberEvent.event_happening?).to be_true
    end

    it "returns true if the current time is between 1 hour before and midnight on the day of a scheduled event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 01:00 pm')
      Timecop.freeze(DateTime.new(2013, 1, 10, 12, 0, 1))
      expect(AllMemberEvent.event_happening?).to be_true
    end

    it "returns false if the current time is not during an all day event or 1 hour before a scheduled event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/09/2013 12:00 am')
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 02:00 pm')
      FactoryGirl.create(:all_member_event, :scheduled => '1/11/2013 12:00 am')
      Timecop.freeze(DateTime.new(2013, 1, 10, 12, 0))
      expect(AllMemberEvent.event_happening?).to be_false
    end
  end

end
