require 'helper'

testcase Smeagol::App do

  context "Testing Routes" do
    include Rack::Test::Methods

    # TODO: Wait, there is no `before :all`?
    setup do
      @wiki_directory = test_wiki('smeagol-test')
    end

    test "root" do
      get '/'
      body = last_response.body.gsub(/^\s+| +$/, '')
      body.assert.include?('<html>')
      body.assert.include?('<title>Smeagol - Home</title>')
      body.assert.include?('<p>Welcome to the Home page!</p>')
    end

    test "Test Page" do
      get '/Test-page'
      body = last_response.body.gsub(/^\s+| +$/, '')
      body.assert.include?('<h1>Test page</h1>')
      body.assert.include?('<p>This is the <strong>test</strong> <em>page</em>.</p>')
      body.assert.include?('<li>Item 1</li>')
    end

    test "Code Page" do
      get '/Code-page'
      body = last_response.body.gsub(/^\s+| +$/, '')
      body.assert.include? <<-END.gsub(/^\s+| +$/, '')
        <h1>Code page</h1>
        <div id="content">
          <p>This is Ruby code:</p>
        
          <div class="highlight"><pre><span class="k">def</span> <span class="nf">hello</span>
            <span class="nb">puts</span> <span class="s2">"Hello, World!"</span>
          <span class="k">end</span>
          </pre>
          </div>
        </div>
      END
    end

    #
    def app
      @app ||= (
        path = @wiki_directory

        Rack::Builder.new do
          Smeagol::App.set :environment, :test
          Smeagol::App.set :repositories, [Smeagol::Repository.new(:path => path)]
          Smeagol::App.set :cache_enabled, false
          Smeagol::App.set :mount_path, ''

          run Smeagol::App
        end
      )
    end

  end

end
