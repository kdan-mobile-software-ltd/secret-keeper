require 'bundler/setup'
require 'yaml'
require 'secret-keeper'

Bundler.setup

ENV['RAILS_ENV'] ||= 'test'

RSpec.configure do |config|
  # some (optional) config here
end
