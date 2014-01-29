require 'mailgun/mailbox/version'
require 'rest_client'
require 'json'
require 'mail'
require 'mailgun/mailbox/wait_until'
require 'mailgun/mailbox/with_rescue'


module Mailgun
  module Mailbox
    @mailgun_user = 'api'
    @mailgun_host = 'api.mailgun.net'
    @mailbox_timeout = 90

    @found_message = nil
    @generated_email = nil

    def self.get_events_url
      base_url = "https://#{@mailgun_host}/v2/#{@mailbox_domain}/events"
      add_auth(base_url)
    end

    def self.add_auth(base_url)
      uri = URI(base_url)
      uri.user=@mailgun_user
      uri.password=@mailgun_key
      uri.to_s
    end

    def self.set_generated_email(email)
      @generated_email = email
    end


    module_function
    def look_for_email(subject, to_address)

      to_address=@generated_email if to_address.nil?

      t = events_request({:params => {:subject=>subject, :recipient => to_address}})

      return if t['items'].count==0

      m=nil
      if t['items'][0].has_key?('storage')
        m = get_first_message(t)
      else
        m = get_message_by_mid(t['items'][0]['message']['headers']['message-id'])
      end

      return if m.nil?

      found_message = nil
      found_message = m.text_part.decoded if m.text_part
      found_message = m.html_part.decoded if m.html_part and found_message.nil?
      found_message = m.body.decoded if found_message.nil?
      return if found_message.nil?
      return if found_message.length==0
      @found_message = found_message

    end

    alias :_look_for_email :look_for_email

    def get_message_by_mid(message_id)
      t = events_request({:params => {'message-id' => message_id}})
      return if !t.has_key?('items')
      return if t['items'].count==0
      return if !t['items'][0].has_key?('storage')
      get_first_message(t)
    end

    def get_first_message(t)
      msg_url = add_auth(t['items'][0]['storage']['url'])
      r = RestClient.get add_auth(msg_url), {'accept' => 'message/rfc2822'}
      t = JSON.parse(r.body)
      m = Mail.new(t['body-mime'])
    rescue RestClient::ResourceNotFound=>e
      return nil
    end

    def events_request(params)
      ::Mailgun::RetryHelper::with_rescue_many([RestClient::BadGateway, RestClient::RequestTimeout], 5) do
        r = RestClient.get get_events_url, params
        JSON.parse(r.body)
      end
    end

    def self.wait_for_email(subject, to_address, timeout=nil)
      timeout = @mailbox_timeout if timeout.nil?
      to_addrhttps://github.com/JWPlayer/mailgun-mailboxess=@generated_email if to_address.nil?
      ::Mailgun::WaitUntil::wait_until(timeout, message="Email to '#{to_address}' with subject '#{subject}' was not found within #{@mailbox_timeout}") do
        look_for_email(subject, to_address)
      end
    end

    def self.get_message_urls(to_address)
      t = events_request({:params => {:recipient => to_address}})
      return if t['items'].count==0
      t['items'].each do |item|
        if item.has_key?('storage')
          yield item['storage']['url']
        else
          t = events_request({:params => {'message-id' => item['message']['headers']['message-id']}})
          yield t['items'][0]['storage']['url']
        end
      end
    end

    module_function

    # deletes all email message in mailbox addressed to @to_address
    # please note this method is tested to work on <100 messages in mailbox
    # it would run slow if you'll try to delete 1000s of messages
    # so it is suggested to run it after every test case
    # @param [String] to_address
    def delete_emails_to!(to_address)
      get_message_urls(to_address) do |url|
        RestClient.delete add_auth(url)
      end
    end

    module_function

    def clear_mailbox(to_address=nil)
      to_address=@generated_email if to_address.nil?
      delete_emails_to!(to_address)
    end

    module_function
    #blocks till email message with specific subject and recipient address show up in the mailbox
    #if email message doesn't show up withing <timeout> seconds throw Selenium::WebDriver::Error::TimeOutError exception
    # @param [String] subject
    # @param [String] to_address
    # @param [Integer] timeout (optional)
    # @return [String] return message body
    # @raise Selenium::WebDriver::Error::TimeOutError if email message haven't shown up withing timeout seconds
    def wait_for_email(subject, to_address, timeout=nil)
      timeout = @mailbox_timeout if timeout.nil?
      to_address=@generated_email if to_address.nil?
      ::Mailgun::WaitUntil::wait_until(timeout, message="Email to '#{to_address}' with subject '#{subject}' was not found within #{@mailbox_timeout}") do
        look_for_email(subject, to_address)
      end
    end

    module_function
    # @return [String] = random email address with Mailgun user Domain
    def generate_email
      @generated_email = "bot_test_runner+#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{Random.rand(999)}@#{@mailbox_domain}"
    end

    module_function
    # set configuration
    # @param [String] mailgun_key
    # @param [String] mailbox_domain
    # @param [Integer] mailbox_timeout
    # @param [String] mailgun_host
    def set_config(mailgun_key, mailbox_domain, mailbox_timeout=90, mailgun_host='api.mailgun.net')
      @mailgun_key = mailgun_key
      @mailbox_domain = mailbox_domain
      @mailgun_host = mailgun_host unless mailbox_timeout.nil?
      @mailbox_timeout = mailbox_timeout unless mailbox_timeout.nil?
    end


  end
end
