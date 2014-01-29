# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailgun/mailbox/version'

Gem::Specification.new do |spec|
  spec.name          = "mailgun-mailbox"
  spec.version       = Mailgun::Mailbox::VERSION
  spec.authors       = ["Vladimir Vladimirov"]
  spec.email         = ["vladimir@jwplayer.com"]
  spec.description   = %q{Ruby client for Mailgun API that provides methods to use subset Mailgun Events and Storage API functionality as a disposable email address service.}
  spec.summary       = <<-eos
  This library allows to have a disposable email address service built on top of subset of Mailgun Events and Storage API.
  It does not require creating email address in advance.
  We use this library as a part of our Cucumber Testing Framework to validate that emails are actually get sent to end users.
  Also every test case should be independent from other test cases - email addresses should be unique every time.
eos
  spec.homepage      = "https://github.com/JWPlayer/mailgun-mailbox"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
  spec.add_dependency "rest-client"
  spec.add_dependency "json"
  spec.add_dependency "mail"
  spec.add_dependency "selenium-webdriver"
end
