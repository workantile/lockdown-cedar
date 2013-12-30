require "spec_helper"

describe MemberEmail do
  describe ".free_day_pass_use" do
  	let(:member)	{ FactoryGirl.create(:affiliate_member) }
    let(:mail) 		{ MemberEmail.free_day_pass_use(member) }

    it "renders the headers" do
      mail.subject.should eq("Day pass use")
      mail.to.should eq([member.email])
      mail.from.should eq(["admin@workantile.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi #{member.first_name}")
      mail.body.encoded.should match("#{member.billable_usage_this_month}")
      mail.body.encoded.should match("#{Member::AFFILIATE_FREE_DAY_PASSES}")
    end
  end

  describe ".billable_day_pass_use" do
  	let(:member)	{ FactoryGirl.create(:affiliate_member) }
    let(:mail) 		{ MemberEmail.billable_day_pass_use(member) }

    it "renders the headers" do
      mail.subject.should eq("Billable day pass use")
      mail.to.should eq([member.email])
      mail.from.should eq(["admin@workantile.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi #{member.first_name}")
      mail.body.encoded.should match("#{Member::AFFILIATE_FREE_DAY_PASSES}")
      mail.body.encoded.should match("#{member.billable_usage_this_month}")
    end
  end
end
