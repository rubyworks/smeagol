# Update load path
#$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))

require 'rack/test'
require 'smeagol'

# TODO: Use Grit instead of shell.
def test_wiki
  @__test_wiki__ ||= (
    directory = 'smeagol-test'
    if ::File.directory?("#{directory}/.git")
      #system "cd #{directory} && git reset --hard"
    else
      system "git clone https://github.com/rubyworks/smeagol-test.git"
    end
    directory
  )
end

$stderr.puts "-" * 40
test_wiki
$stderr.puts "-" * 40
$stderr.puts

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
