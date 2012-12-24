module MailerMacros
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def all_emails
  	ActionMailer::Base.deliveries
  end
  
  def reset_email
    ActionMailer::Base.deliveries = []
  end
end