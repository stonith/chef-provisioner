require 'erb'
require 'ostruct'

require 'chef-provisioner/chef'

module ChefProvisioner
  # Help render the bootstrap script
  module Bootstrap
    extend self
    BOOTSTRAP_TEMPLATE = File.read(File.expand_path('../templates/bootstrap.erb', __FILE__)).freeze

    def generate(node_name: '', chef_version: '12.4.1', environment: nil, server: '', first_boot: {}, reinstall: false, audit: false, force: false, retries: 0)
      node_name = node_name.strip
      server = ChefAPI.endpoint if server.empty?
      run_list = first_boot[:run_list] if first_boot[:run_list] # FIXME - symbolize keys instead of the dup here
      run_list = first_boot['run_list'] if first_boot['run_list']
      first_boot.merge!( fqdn: node_name, chef_client: {config: {chef_server_url: server}} )
      client_pem = get_client_key(node_name, run_list, force, retries)
      render(node_name: node_name, client_pem: client_pem, chef_version: chef_version, environment: environment, server: server, first_boot: first_boot, reinstall: reinstall, audit: audit)
    end

    private

    def render(**kwargs)
      ERB.new(BOOTSTRAP_TEMPLATE).result(OpenStruct.new(**kwargs).instance_eval { binding })
    end

    def get_client_key(node_name, run_list, force, retries)
      client_pem = ''
      attempts = 0
      while client_pem.empty? && attempts < retries
        client_pem = ChefProvisioner::Chef.init_server(node_name, run_list: (run_list || []), force: force)
        attempts += 1
        sleep(5)
      end
      client_pem
    end
  end
end
