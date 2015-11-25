require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe ChefProvisioner::Chef do
  include ChefSpec
  let(:name) { 'test' }

  before :all do
    setup_chef_client
  end

  context 'clients' do
    it 'creates clients' do
      ChefProvisioner::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
    end

    it 'generates private keys' do
      key = ChefProvisioner::Chef.create_client(name)
      expect(key).to include('-----BEGIN RSA PRIVATE KEY-----')
      expect(key).to include('-----END RSA PRIVATE KEY-----')
    end

    it 'destroys clients' do
      ChefProvisioner::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      ChefProvisioner::Chef.delete_client(name)
      expect(ChefAPI::Resource::Client.fetch(name)).to be_nil
    end

    it 'fails creation gracefully' do
      ChefProvisioner::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect { ChefProvisioner::Chef.create_client(name) }.to output(/Failed to create client/).to_stdout
    end
  end

  context 'nodes' do
    it 'creates nodes' do
      ChefProvisioner::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
    end

    it 'destroys nodes' do
      ChefProvisioner::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      ChefProvisioner::Chef.delete_node(name)
      expect(ChefAPI::Resource::Node.fetch(name)).to be_nil
    end

    it 'fails creation gracefully' do
      ChefProvisioner::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      expect { ChefProvisioner::Chef.create_node(name) }.to output(/Failed to create node/).to_stdout
    end
  end

  context 'server' do
    it 'creates servers' do
      key = ChefProvisioner::Chef.init_server(name)
      expect(key).to include('-----BEGIN RSA PRIVATE KEY-----')
      expect(key).to include('-----END RSA PRIVATE KEY-----')
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
    end

    it 'nukes servers' do
      ChefProvisioner::Chef.init_server(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      ChefProvisioner::Chef.nuke(name)
      expect(ChefAPI::Resource::Client.fetch(name)).to be_nil
      expect(ChefAPI::Resource::Node.fetch(name)).to be_nil
    end
  end

  context 'bootstrap' do
    let(:node_name) { 'testnode.testdomain' }
    let(:environment) { 'testing' }
    let(:server) { 'http://chef.server.testdomain' }
    let(:first_boot) { { run_list: ['role[testrole]'], fqdn: node_name } }

    it 'renders the client.pem' do
      script = ChefProvisioner::Bootstrap.generate(node_name: node_name)
      expect(script).to include('-----BEGIN RSA PRIVATE KEY-----')
      expect(script).to include('-----END RSA PRIVATE KEY-----')
    end

    it 'renders the node_name' do
      script = ChefProvisioner::Bootstrap.generate(node_name: node_name)
      expect(script).to include("node_name \"#{node_name}\"")
    end

    it 'renders the environment' do
      script = ChefProvisioner::Bootstrap.generate(node_name: node_name, environment: environment)
      expect(script).to include("environment      \"#{environment}\"")
    end

    it 'renders the server' do
      script = ChefProvisioner::Bootstrap.generate(node_name: node_name, server: server)
      expect(script).to include("chef_server_url  \"#{server}\"")
    end

    it 'renders first_boot attributes' do
      script = ChefProvisioner::Bootstrap.generate(node_name: node_name, first_boot: first_boot)
      expect(script).to include(JSON.pretty_generate(first_boot))
    end

    it 'does not propagate whitespace in node name' do
      script = ChefProvisioner::Bootstrap.generate(node_name: " \t #{node_name} \t \n ")
      expect(script).to_not match(/node_name "\s+#{node_name}\s+"/)
    end
  end
end
