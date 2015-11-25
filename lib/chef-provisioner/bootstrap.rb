require 'erb'
require 'ostruct'

require 'chef-provisioner/chef'

module ChefProvisioner
  module Bootstrap
    extend self
    BOOTSTRAP_TEMPLATE = File.read(File.expand_path('../../chef-provisioner/templates/bootstrap.erb', __FILE__)).freeze

    def generate(client_pem:'', chef_version: '12.4.1', environment: 'default', server: 'localhost', node_name: '', first_boot: {})
      params = method(__method__).parameters.map(&:last)
      opts = params.map { |p| [p, eval(p.to_s)] }.to_h
      render(**opts)
    end
  private
    def render(**kwargs)
      ERB.new(BOOTSTRAP_TEMPLATE).result(OpenStruct.new(**kwargs).instance_eval{ binding })
    end
  end
end
