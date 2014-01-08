require 'spec_helper'

describe AllMemberEvent do
  let!(:all_member_event) { FactoryGirl.create(:all_member_event) }
  # Timecop creates datetime objects in UTC, while Rails uses the current timezone offset when storing and
  # retrieving datetime objects from the database. So we need to current offset to using Timecop so that datetime
  # objects are compared correctly when retrieving data from the database.
  let(:current_offset)    { DateTime.current.offset }

  it { should respond_to :name }
  it { should respond_to :scheduled }

  it { should validate_presence_of :name }
  it { should validate_presence_of :scheduled }

  describe ".event_happening?" do
    it "returns true if the current time is during an all day event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 12:00 am')
      Timecop.freeze(DateTime.new(2013, 1, 10, 13, 0, 0, current_offset))
      expect(AllMemberEvent.event_happening?).to be_true
    end

    it "returns true if the current time is between 1 hour before and midnight on the day of a scheduled event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 01:00 pm')
      AllMemberEvent.all.each { |a| puts a.inspect }
      Timecop.freeze(DateTime.new(2013, 1, 10, 12, 1, 0, current_offset))
      expect(AllMemberEvent.event_happening?).to be_true
    end

    it "returns false if the current time is not during an all day event or 1 hour before a scheduled event" do
      FactoryGirl.create(:all_member_event, :scheduled => '1/09/2013 12:00 am')
      FactoryGirl.create(:all_member_event, :scheduled => '1/10/2013 02:00 pm')
      FactoryGirl.create(:all_member_event, :scheduled => '1/11/2013 12:00 am')
      Timecop.freeze(DateTime.new(2013, 1, 10, 12, 0, 0, current_offset))
      expect(AllMemberEvent.event_happening?).to be_false
    end
  end

end
