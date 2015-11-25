require 'erb'
require 'ostruct'

require 'chef-provisioner/chef'

module ChefProvisioner
  # Help render the bootstrap script
  module Bootstrap
    extend self
    BOOTSTRAP_TEMPLATE = File.read(File.expand_path('../../chef-provisioner/templates/bootstrap.erb', __FILE__)).freeze

    def generate(client_pem:'', chef_version: '12.4.1', environment: 'default', server: 'localhost', node_name: '', first_boot: {})
      render(client_pem: client_pem, chef_version: chef_version, environment: environment, server: server, node_name: node_name, first_boot: first_boot)
    end

    private

    def render(**kwargs)
      ERB.new(BOOTSTRAP_TEMPLATE).result(OpenStruct.new(**kwargs).instance_eval { binding })
    end
  end
end
