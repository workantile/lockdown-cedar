class ShoutOutEmail < ActionMailer::Base
  default from: "admin@workantile.com"

  def absent_members_email(absent_members)
    @members = absent_members
    mail to: "shoutout@workantile.com", subject: "Members absent 3 weeks or more"
  end

end
