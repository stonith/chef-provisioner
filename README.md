![travis badge](https://travis-ci.org/dalehamel/chef-provisioner.svg)

# Chef zero bootstrap

This is a simple client to bootstrap against a chef-zero server

At the minimum

```
require 'chef-provisioner'

ChefProvisioner::Config.setup(server: 'https://my.awesome.chef.server', client_key_path: client_pem_path, client: 'your_client_name')

script = ChefProvisioner::Bootstrap.generate(
  node_name: 'foo.bar.mydomain'
)

File.write('./my_script', script)
system('./my_script')
```

The resulting file (my_script above) may be executed to bootstrap the server in question

You may (and should) also specify other attributes:

```
script = ChefProvisioner::Bootstrap.generate(
  node_name: 'foo.bar.mydomain',
  environment: 'master',
  first_boot: {
    run_list: [ 'role[my-sweet-role]' ]
  }
)

```

Note:

* first\_boot will automatically get 'fqdn' set to 'node\_name'
* The bootstrap server is set automatically from the Chef endpoint
* Node names are trimmed of leading and trailing whitespace
