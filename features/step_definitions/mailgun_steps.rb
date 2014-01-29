When(/^I send email to random mailbox with random subject$/) do

  Mailgun::Mailbox.set_config(ENV['MAILGUN_API_KEY'], ENV['MAILGUN_HOST'], 20)
  @email_address = Mailgun::Mailbox.generate_email()

  #send email with SMTP and mailgun account
  options = { :address              => "smtp.mailgun.org",
              :port                 => 587,
              :domain               => ENV['MAILGUN_HOST'],
              :user_name            => "postmaster@#{ENV['MAILGUN_HOST']}",
              :password             => ENV['SMTP_PASSWORD'],
              :authentication       => 'plain',
              :enable_starttls_auto => true  }


  Mail.defaults do
    delivery_method :smtp, options
  end

  @subject = "Random Subject #{Random.rand(999)}"

  @body = 'testing mailgun mailbox'

  Mail.deliver({to:"#{@email_address}", from:"#{@email_address}", subject: "#{@subject}", body: @body})

end

Then(/^I can load this message from mailbox$/) do
  email = Mailgun::Mailbox.wait_for_email(@subject, @email_address)
  email.nil?.should_not be_true
  email.should == @body
end

When(/^I delete this message$/) do
  Mailgun::Mailbox.delete_emails_to!(@email_address)
end

Then(/^I don't see this message in mailbox$/) do
  email = nil
  found_email = false
  begin
    email = Mailgun::Mailbox.wait_for_email(@subject, @email_address, 15)
    found_email = true
  rescue Selenium::WebDriver::Error::TimeOutError=>e
    email = nil
    found_email = false
  end
  email.nil?.should be_true
  found_email.should be_false
end