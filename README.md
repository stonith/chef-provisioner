![travis badge](https://travis-ci.org/dalehamel/chef-provisioner.svg)

# Chef zero bootstrap

This is a simple client to bootstrap against a chef-zero server

At the minimum

```
script = ChefProvisioner::Bootstrap.generate(
  node_name: 'foo.bar.mydomain'
)

File.write('./my_script', script)
system('./my_script')
```

You may (and should) also specify other attributes:

```
script = ChefProvisioner::Bootstrap.generate(
  node_name: 'foo.bar.mydomain',
  environment: 'master',
  server: 'https://my.awesome.chef.server',
  first_boot: {
    fqdn: node_name,
    run_list: [ 'role[my-sweet-role]' ]
  }
)

```
