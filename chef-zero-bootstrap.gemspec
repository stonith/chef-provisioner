lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef-zero-bootstrap/version'

Gem::Specification.new do |s|
  s.name        = 'chef-zero-bootstrap'
  s.version     = ChefZeroBootstrap::VERSION
  s.date        = '2015-11-24'
  s.summary     = 'Bootstrap against a chef-zero server'
  s.description = 'Provides a means of easily bootstrapping against a fake, chef-zero server'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = Dir['lib/**/*']
  s.homepage    =
    'http://rubygems.org/gems/chef-zero-bootstrap'
  s.license       = 'MIT'
  s.add_runtime_dependency 'chef-api', ['=0.5.0']
  s.add_development_dependency 'rake', ['=10.4.2']
  s.add_development_dependency 'simplecov', ['=0.10.0']
  s.add_development_dependency 'rspec', ['=3.2.0']
end
