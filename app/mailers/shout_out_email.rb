class ShoutOutEmail < ActionMailer::Base
  default from: "admin@workantile.com"
  default to: "shoutout@workantile.com, maintainers@workantile.com"
  default subject: "Members absent 3 weeks or more"

  def absent_members_email(absent_members)
    @absent_members = absent_members
    mail
  end

end
