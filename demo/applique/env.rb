#require 'rubygems'
#require 'cucumber'
require 'rack/test'

# Update load path
#$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))

require 'smeagol'

# Stop test if test wiki path is not set
#if !ENV.has_key?('SMEAGOL_TEST_WIKI_PATH')
#  puts 'You must set SMEAGOL_TEST_WIKI_PATH in your environment to run the tests.'
#  exit(1);
#end

# TODO: Use Grit instead of shell.

def test_wiki
  @__test_wiki__ ||= (
    If File.directory?(test_wiki + '/.git')
      `cd #{test_wiki}; git reset --hard`
    else
      `git clone https://github.com/rubyworks/smeagol-test.git`
    end
    'smeagol-test'
  )
end

Smeagol::App.set :environment, :test
Smeagol::App.set :repositories, [Smeagol::Repository.new(:path => test_wiki)]
Smeagol::App.set :cache_enabled, false

#World do
  def app
    @app = Rack::Builder.new do
      run Smeagol::App
    end
  end
  include Rack::Test::Methods
#end
