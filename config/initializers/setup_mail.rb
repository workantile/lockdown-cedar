  # mailer setup
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => ENV['GMAIL_USERNAME'],
    :password             => ENV['GMAIL_PASSWORD'],
    :authentication       => 'plain',
    :domain               => 'workantile.com',
    :enable_starttls_auto => true
  }
