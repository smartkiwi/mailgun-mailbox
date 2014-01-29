require 'selenium/webdriver/common/error'
require 'selenium/webdriver/common/wait'
module Mailgun
  module WaitUntil

    def self.wait_until(timeout = 10, message=nil, &block)
      wait = Selenium::WebDriver::Wait.new(:timeout => timeout, :message => message)
      wait.until &block
    end

  end
end