require 'citron'
require 'ae'

#require 'mocha'
require 'smeagol'

#$:.unshift(File.dirname(__FILE__))
#require File.expand_path(File.dirname(__FILE__) + '/../lib/smeagol')

# Stop test if test wiki path is not set
#if !ENV.has_key?('SMEAGOL_TEST_WIKI_PATH')
#  puts 'You must set SMEAGOL_TEST_WIKI_PATH in your environment to run the tests.'
#  exit(1);
#end

# TODO: Use Grit instead of shell.
def test_wiki
  @__test_wiki__ ||= (
    directory = 'tmp/smeagol-test'
    if ::File.directory?("#{directory}/.git")
      #system "cd #{directory} && git reset --hard"
    else
      system "cd tmp; git clone https://github.com/rubyworks/smeagol-test.git"
    end
    directory
  )
end

