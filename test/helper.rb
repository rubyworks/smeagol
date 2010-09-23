require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'

$:.unshift(File.dirname(__FILE__))
require File.expand_path(File.dirname(__FILE__) + '/../lib/smeagol')

# Stop test if test wiki path is not set
if !ENV.has_key?('SMEAGOL_TEST_WIKI_PATH')
  puts 'You must set SMEAGOL_TEST_WIKI_PATH in your environment to run the tests.'
  exit(1);
end
