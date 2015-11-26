require 'erb'
require 'ostruct'

require 'chef-provisioner/chef'

module ChefProvisioner
  # Help render the bootstrap script
  module Bootstrap
    extend self
    BOOTSTRAP_TEMPLATE = File.read(File.expand_path('../../chef-provisioner/templates/bootstrap.erb', __FILE__)).freeze

    def generate(node_name: '', chef_version: '12.4.1', environment: nil, server: '', first_boot: {})
      node_name = node_name.strip
      server = ChefAPI.endpoint if server.empty?
      client_pem = ChefProvisioner::Chef.init_server(node_name)
      first_boot.merge!( fqdn: node_name, chef_client: {config: {chef_server_url: server}} )
      render(node_name: node_name, client_pem: client_pem, chef_version: chef_version, environment: environment, server: server, first_boot: first_boot)
    end

    private

    def render(**kwargs)
      ERB.new(BOOTSTRAP_TEMPLATE).result(OpenStruct.new(**kwargs).instance_eval { binding })
    end
  end
end
