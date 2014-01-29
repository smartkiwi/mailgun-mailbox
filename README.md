# Mailgun::Mailbox

  This library allows to have a disposable email address service built on top of subset of Mailgun Events and Storage API.
  It does not require creating email address in advance.
  We use this library as a part of our Cucumber Testing Framework to validate that emails are actually get sent to end users.
  Also every test case should be independent from other test cases - email addresses should be unique every time.


## Installation

Add this line to your application's Gemfile:

    gem 'mailgun-mailbox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mailgun-mailbox

## Usage

    See features/steps_definitions.rb for detailed example

````ruby
require 'mailgun/mailbox'

#set thing up
#Mailgun::Mailbox.set_config(<your mailgun api key>, <your mailgun domain>)
#generate random email address with your mailgun domain
@email_address = Mailgun::Mailbox.generate_email()

#Here your app will send email message with specific subject to generated email address
#...

email = Mailgun::Mailbox.wait_for_email(<know subject>, email_address)
#print email body
puts email

#delete all emails sent to address:
Mailgun::Mailbox.delete_emails_to!(email_address)
````

## Testing package

    $ cucumber MAILGUN_API_KEY=<your api key> MAILGUN_HOST=<your domain name registered with mailgun> SMTP_PASSWORD=<smtp password provided by mailgun for your domain>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
