# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'smeagol/version'

Gem::Specification.new do |s|
  s.name        = "smeagol"
  s.version     = Smeagol::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["benbjohnson@yahoo.com"]
  s.homepage    = "http://smeagolrb.info"
  s.summary     = "A read-only server for Gollum wikis"
  s.executables = ['smeagol', 'smeagold', 'smeagol-static']
  s.default_executable = 'smeagol'

  s.add_dependency('rack', '~> 1.2')
  s.add_dependency('gollum', '~> 1.1')
  s.add_dependency('sinatra', '~> 1.0')
  s.add_dependency('OptionParser', '~> 0.5')
  s.add_dependency('daemons', '~> 1.1')

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
  s.add_development_dependency('mocha')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('rspec')
  s.add_development_dependency('capybara')

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w(README.md)
  s.require_path = 'lib'
end
