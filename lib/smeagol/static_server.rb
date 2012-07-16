require 'fileutils'
require 'tmpdir'
#require 'brite/config'

module Smeagol

  module Static

    # Server is a Rack-based server useful for testing sites locally.
    # Most sites cannot be fully previewed by loading static files into a browser.
    # Rather, a webserver is required to render and navigate a site completely. 
    # So this light server is provided to facilitate this.
    #
    # NOTE: We would be just as happy to depend on thin instead of rolling our
    # own, but thin lacks any ability to default directory requests to  index.html
    # files. 
    #
    class Server

      # Optional Rack configuration file.
      RACK_FILE = 'config.ru'

      #
      def self.run(options)
        new(options).start
      end

      # Server options, parsed from command line.
      attr :options

      # Setup new instance of Server.
      def initialize(options={})
        @options = options

        @root = settings.static_path

        @options[:app] = app
        @options[:pid] = "#{tmp_dir}/pids/server.pid"

        @options[:Port] ||= '4567'

        require_rack
      end

      #
      def require_rack
        require 'rack'
        require 'rack/server'
        require 'rack/handler'
        require 'rack/builder'
        require 'rack/directory'
        require 'rack/file'
      end

      # THINK: Should we be using a local tmp directory instead?
      #        Then again, why do we need them at all, really?

      # Temporary directory used by the rack server.
      def tmp_dir
        @tmp_dir ||= File.join(Dir.tmpdir, 'smeagol', root)
      end

      # Start the server.
      def start
        if options[:build]
        end

        Signal.trap('TERM') do
          Process.kill('KILL', 0)
        end

        #ensure_smeagol_site

        # create required tmp directories if not found
        %w(cache pids sessions sockets).each do |dir_to_make|
          FileUtils.mkdir_p(File.join(tmp_dir, dir_to_make))
        end

        ::Rack::Server.start(options)
      end

      # Ensure root is a Smeagol.
      #def ensure_smeagol_site
      #  return true if File.exist?(rack_file)
      #  #return true if config.file
      #  abort "Not a smeagol site."
      #end

      # Load settings.
      def settings
        @settings ||= Smeagol::Settings.load #(root)
      end

      # Site root directory.
      def root
        @root
      end

      # Configuration file for server.
      def rack_file
        RACK_FILE
      end

      # If the site has a `brite.ru` file, that will be used to start the server,
      # otherwise a standard Rack::Directory server ise used.
      def app
        @app ||= (
          if ::File.exist?(rack_file)
            app, options = Rack::Builder.parse_file(rack_file, opt_parser)
            @options.merge!(options)
            app
          else
            root = self.root
            Rack::Builder.new do
              use Index, root
              run Rack::Directory.new("#{root}")
            end
          end
        )
      end

      # Rack middleware to serve `index.html` file by default.
      class Index
        def initialize(app, root)
          @app  = app
          @root = root || Dir.pwd
        end

        def call(env)
          path = Rack::Utils.unescape(env['PATH_INFO'])
          index_file = File.join(@root, path, 'index.html')
          if File.exist?(index_file)
            [200, {'Content-Type' => 'text/html'}, File.new(index_file)]
          else
            @app.call(env) #Rack::Directory.new(@root).call(env)
          end
        end
      end

      #
      #def log_path
      #  "_smeagol.log"
      #end

      #
      #def middleware
      #  middlewares = []
      #  #middlewares << [Rails::Rack::LogTailer, log_path] unless options[:daemonize]
      #  #middlewares << [Rails::Rack::Debugger]  if options[:debugger]
      #  Hash.new(middlewares)
      #end

    end

  end

end
