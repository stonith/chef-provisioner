require 'simplecov'
SimpleCov.start
require 'rspec'
require 'chef_zero/server'

require 'tempfile'
require 'openssl'
require 'uri/generic'

require File.expand_path('../../lib/chef-provisioner.rb', __FILE__)

# Start a chef server arround chef tests
module ChefSpec
  def self.append_features(mod)
    mod.class_eval %[
      around(:each) do |example|
        with_chef_server do
          example.run
        end
      end
    ]
  end
end

def with_chef_server
  ChefProvisioner::Config.setup
  uri = URI(ChefProvisioner::Config.server)
  server = ChefZero::Server.new(host: uri.host, port: uri.port)
  server.start_background
  yield
  server.stop
end

def match_fixture(name, actual)
  path = File.expand_path("fixtures/#{name}.txt", File.dirname(__FILE__))
  File.open(path, 'w') { |f| f.write(actual) } if ENV['FIXTURE_RECORD']
  expect(actual).to eq(File.read(path))
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
