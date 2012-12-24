class MemberEmail < ActionMailer::Base
  default from: "admin@workantile.com"

  def free_day_pass_use(member)
    @member = member
    mail to: @member.email, subject: "Day pass use"
  end

  def billable_day_pass_use(member)
    @member = member
    mail to: @member.email, subject: "Billable day pass use"
  end
end
