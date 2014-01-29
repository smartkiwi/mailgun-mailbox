$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','..','lib'))

require'rspec/expectations'
require 'mailgun/mailbox'
require 'mail'