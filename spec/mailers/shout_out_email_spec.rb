require "spec_helper"

describe ShoutOutEmail do
  describe ".absent_members_email" do
    before(:each) do
      @members = [stub_model(Member, :full_name => "Joe Blow", :email => "foo@bar.com", :last_day_present => Date.new(2013, 1, 10))]
      Member.stub(:members_absent) { @members }
      @mail = ShoutOutEmail.absent_members_email(@members)
    end

    it "renders the headers" do
      @mail.to.should eq(["shoutout@workantile.com", "maintainers@workantile.com"])
      @mail.subject.should eq("Members absent 3 weeks or more")
      @mail.from.should eq(["admin@workantile.com"])
    end

    it "renders the body" do
      @mail.body.encoded.should match("#{@members[0].full_name}")
      @mail.body.encoded.should match("#{@members[0].email}")
      @mail.body.encoded.should match("#{@members[0].last_day_present.strftime('%m/%d/%Y')}")
    end
  end

end
