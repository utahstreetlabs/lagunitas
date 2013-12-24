require 'rubygems'
require 'bundler'

Bundler.setup

require 'mocha/api'
require 'rspec'
require 'ladon'
require 'lagunitas/resource/base'

Ladon.hydra = Typhoeus::Hydra.new
Ladon.logger = Logger.new('/dev/null')

Lagunitas::Resource::Base.base_url = 'http://localhost:4001'

RSpec.configure do |config|
  config.mock_with :mocha
end
