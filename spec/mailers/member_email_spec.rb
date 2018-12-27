require 'rails_helper'

describe MemberEmail do
  describe ".free_day_pass_use" do
  	let(:member)	{ FactoryBot.create(:affiliate_member) }
    let(:mail) 		{ MemberEmail.free_day_pass_use(member) }

    it "renders the headers" do
      expect(mail.subject).to eq("Day pass use")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(["admin@workantile.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{member.first_name}")
      expect(mail.body.encoded).to match("#{member.countable_usage_this_month}")
      expect(mail.body.encoded).to match("#{Member::AFFILIATE_FREE_DAY_PASSES}")
    end
  end

  describe ".billable_day_pass_use" do
  	let(:member)	{ FactoryBot.create(:affiliate_member) }
    let(:mail) 		{ MemberEmail.billable_day_pass_use(member) }

    it "renders the headers" do
      expect(mail.subject).to eq("Billable day pass use")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(["admin@workantile.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{member.first_name}")
      expect(mail.body.encoded).to match("#{Member::AFFILIATE_FREE_DAY_PASSES}")
      expect(mail.body.encoded).to match("#{member.billable_usage_this_month}")
    end
  end
end
