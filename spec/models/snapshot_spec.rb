require 'spec_helper'

describe Snapshot do

	describe "validations" do
		before(:each) do
			@snapshot = FactoryGirl.create(:snapshot)
		end

		it { should validate_presence_of(:category) }
		it { should validate_presence_of(:item) }
		it { should validate_presence_of(:count) }
		it { should validate_presence_of(:snapshot_date) }
	end

	describe ".take_snapshot" do
		it "should create a record for each membership type and billing plan" do
			nbr_records = Member::BILLING_PLANS.count + Member::MEMBER_TYPES.count
			expect {
				Snapshot.take_snapshot
			}.to change(Snapshot, :count).by(nbr_records)
		end
	end

end
