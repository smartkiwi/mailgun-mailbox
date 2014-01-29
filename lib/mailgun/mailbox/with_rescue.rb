module Mailgun
  module RetryHelper
    def self.with_rescue(exception, limit=1, &block)

      try=0
      begin
        block.call(try)
      rescue exception
        try+=1
        retry if try<=limit
      end
    end

    def self.with_rescue_many(exceptions, limit=1, &block)

      try=0
      begin
        block.call(try)
      rescue *exceptions
        try+=1
        retry if try<=limit
      end
    end

  end
end

=begin
usage example
    RetryHelper::with_rescue(Selenium::WebDriver::Error::StaleElementReferenceError, 5) do
      page_headline.include?('Your Billing Information')
    end

=end