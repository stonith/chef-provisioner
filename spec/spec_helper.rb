require 'simplecov'
SimpleCov.start
require 'rspec'
require 'chef_zero/server'

require 'tempfile'
require 'openssl'

require File.expand_path('../../lib/chef-zero-bootstrap.rb', __FILE__)

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

def setup_chef_client
  client_file = Tempfile.new('chef-zero-bootstrap-client')
  client_file.write(OpenSSL::PKey::RSA.new(2048).to_s)
  client_file.close
  ChefZeroBootstrap::Chef.configure(endpoint: "http://#{Socket.gethostname}:5000", key_path: client_file.path, client: 'test')
end


def with_chef_server
  setup_chef_client
  server = ChefZero::Server.new(host: '0.0.0.0', port: 5000)
  server.start_background
  yield
  server.stop
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
