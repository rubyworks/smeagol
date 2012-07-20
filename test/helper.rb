require 'citron'
require 'ae'
require 'fileutils'
#require 'mocha'
require 'smeagol'
require 'rack/test'

# Shut-off verbose output from Smeagol.
$QUIET = true

#$:.unshift(File.dirname(__FILE__))
#require File.expand_path(File.dirname(__FILE__) + '/../lib/smeagol')

# Stop test if test wiki path is not set
#if !ENV.has_key?('SMEAGOL_TEST_WIKI_PATH')
#  puts 'You must set SMEAGOL_TEST_WIKI_PATH in your environment to run the tests.'
#  exit(1);
#end

# TODO: Use Grit instead of shell.
def test_wiki(directory='smeagol-test')
  $test_wiki ||= {}
  $test_wiki[directory] ||= (
    directory = File.join('tmp', directory)

    if ::File.directory?("#{directory}/.git")
      #system "cd #{directory} && git reset --hard"
    else
      system "git clone https://github.com/rubyworks/smeagol-test.git #{directory}"
    end

    directory
  )
end

=begin
class TestWiki
  include Rack::Test::Methods 

  # TODO: Use Grit instead of shell.
  def self.clone(directory='smeagol-test')
    if ::File.directory?("#{directory}/.git")
      #system "cd #{directory} && git reset --hard"
    else
      system "git clone https://github.com/rubyworks/smeagol-test.git #{directory}"
    end
    new(directory)
  end

  #
  def initialize(directory)
    @directory = directory
    Smeagol::App.set :environment, :test
    Smeagol::App.set :repositories, [Smeagol::Repository.new(:path => directory)]
    Smeagol::App.set :cache_enabled, false
  end

  #
  attr :directory

  #
  def app
    @app ||= Rack::Builder.new do
      run Smeagol::App
    end
  end

  # Helper method.
  def get_content(body)
    body = body.gsub(/^.+<article>\n/m, '')
    body = body.gsub(/\n<\/article>.+$/m, '')
    return body
  end
end
=end

