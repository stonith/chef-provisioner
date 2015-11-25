require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe ChefZeroBootstrap::Chef do
  include ChefSpec
  let(:name) { 'test' }

  context 'clients' do
    it 'creates clients' do
      ChefZeroBootstrap::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
    end

    it 'generates private keys' do
      key = ChefZeroBootstrap::Chef.create_client(name)
      expect(key).to include('-----BEGIN RSA PRIVATE KEY-----')
      expect(key).to include('-----END RSA PRIVATE KEY-----')
    end

    it 'destroys clients' do
      ChefZeroBootstrap::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      ChefZeroBootstrap::Chef.delete_client(name)
      expect(ChefAPI::Resource::Client.fetch(name)).to be_nil
    end

    it 'fails creation gracefully' do
      ChefZeroBootstrap::Chef.create_client(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect { ChefZeroBootstrap::Chef.create_client(name) }.to output(/Failed to create client/).to_stdout
    end
  end

  context 'nodes' do
    it 'creates nodes' do
      ChefZeroBootstrap::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
    end

    it 'destroys nodes' do
      ChefZeroBootstrap::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      ChefZeroBootstrap::Chef.delete_node(name)
      expect(ChefAPI::Resource::Node.fetch(name)).to be_nil
    end

    it 'fails creation gracefully' do
      ChefZeroBootstrap::Chef.create_node(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      expect { ChefZeroBootstrap::Chef.create_node(name) }.to output(/Failed to create node/).to_stdout
    end
  end

  context 'server' do
    it 'creates servers' do
      key = ChefZeroBootstrap::Chef.init_server(name)
      expect(key).to include('-----BEGIN RSA PRIVATE KEY-----')
      expect(key).to include('-----END RSA PRIVATE KEY-----')
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
    end

    it 'nukes servers' do
      ChefZeroBootstrap::Chef.init_server(name)
      expect(ChefAPI::Resource::Client.fetch(name).name).to eq(name)
      expect(ChefAPI::Resource::Node.fetch(name).name).to eq(name)
      ChefZeroBootstrap::Chef.nuke(name)
      expect(ChefAPI::Resource::Client.fetch(name)).to be_nil
      expect(ChefAPI::Resource::Node.fetch(name)).to be_nil
    end
  end
end
