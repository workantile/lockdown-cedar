require 'rails_helper'

describe ShoutOutEmail do
  describe ".absent_members_email" do
    before(:each) do
      @members = [instance_double(Member, full_name: "Joe Blow", email: "foo@bar.com", last_day_present: Date.new(2013, 1, 10))]
      allow(Member).to receive(:members_absent) { @members }
      @mail = ShoutOutEmail.absent_members_email(@members)
    end

    it "renders the headers" do
      expect(@mail.to).to eq(["shoutout@workantile.com", "maintainers@workantile.com"])
      expect(@mail.subject).to eq("Members absent 3 weeks or more")
      expect(@mail.from).to eq(["admin@workantile.com"])
    end

    it "renders the body" do
      expect(@mail.body.encoded).to match("#{@members[0].full_name}")
      expect(@mail.body.encoded).to match("#{@members[0].email}")
      expect(@mail.body.encoded).to match("#{@members[0].last_day_present.strftime('%m/%d/%Y')}")
    end
  end

end
