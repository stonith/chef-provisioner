require 'openssl'
require 'socket'

require 'chef-provisioner/chef'

module ChefProvisioner
  module Config
    extend self

    attr_reader :server, :client_key, :client

    def setup(server: nil, client_key: nil, client_key_path: nil, client: nil)
      @server = server || "http://#{my_ip}:#{get_free_port}"
      @client_key = client_key || client_key_path || setup_chef_client_file
      @client = client || 'testing-client'
      ChefProvisioner::Chef.configure(endpoint: @server, key_path: @client_key, client: @client)
    end

  private

    def get_free_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      port = socket.local_address.ip_port
      socket.close
      port
    end

    def my_ip
      Socket.ip_address_list.find{|x| x.ipv4? && !x.ipv4_loopback?}.ip_address
    end

    def setup_chef_client_file
      client_file = Tempfile.new('chef-provisioner-client')
      client_file.write(OpenSSL::PKey::RSA.new(2048).to_s)
      client_file.close
      client_file.path
    end
  end
end
