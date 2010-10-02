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
  s.executables = ["smeagol"]
  s.default_executable = 'smeagol'

  s.add_dependency('rack', '= 1.2.0')
  s.add_dependency('gollum', '~> 1.0.1')
  s.add_dependency('sinatra', '~> 1.0')
  s.add_dependency('mustache', '~> 0.11.2')
  s.add_dependency('OptionParser', '~> 0.5.1')

  s.add_development_dependency('rake', '~> 0.8.3')
  s.add_development_dependency('minitest', '~> 1.7.0')
  s.add_development_dependency('mocha', '~> 0.9.8')
  s.add_development_dependency('cucumber', '~> 0.8.5')
  s.add_development_dependency('rspec', '~> 1.3.0')
  s.add_development_dependency('capybara', '~> 0.3.9')

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.require_path = 'lib'
end
