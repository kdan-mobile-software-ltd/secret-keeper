require 'bundler/setup'
require 'secret-keeper'
require 'yaml'

Bundler.setup

ENV['RAILS_ENV'] ||= 'test'

RSpec.configure do |config|
  # some (optional) config here
end
