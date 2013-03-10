require "spec_helper"

describe ShoutOutEmail do
  describe ".absent_members_email" do
    let(:members)  { [FactoryGirl.create(:affiliate_member)] }
    let(:mail)    { ShoutOutEmail.absent_members_email(members) }

    it "renders the headers" do
      mail.subject.should eq("Members absent 3 weeks or more")
      mail.to.should eq(["shoutout@workantile.com"])
      mail.from.should eq(["admin@workantile.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("#{members[0].full_name}")
    end
  end

end
