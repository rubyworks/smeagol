# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'smeagol/version'
require 'bundler'

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

  s.add_bundler_dependencies

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.require_path = 'lib'
end
