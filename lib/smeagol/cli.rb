module Smeagol

  # Smeagol::CLI module is a function module that provide
  # all command line interfaces.
  #
  module CLI
    extend self

    # Initialize Gollum wiki site for use with Smeagol.
    #
    def init(argv)
      parser.banner = "usage: smeagol init [OPTIONS] [WIKI-URI]"

      #parser.on('--static', 'Static mode site?') do
      #  options['static'] = true
      #end

      #parser.on('-b', '--build-dir [DIRECTORY]') do |dir|
      #  options[:build_dir] = dir
      #end

      # TODO: support more settings options for creating setup

      Console.init(*parse(argv))
    end

    # Convert to static site.
    #
    # Update wiki repo and update/clone static site repo, if designated
    # by settings.
    #
    # Returns nothing.
    def compile(argv)
      options[:update] = true
      options[:build]  = true

      parser.banner = "usage: smeagol static [OPTIONS]"

      parser.on('-U' '--no-update', 'skip repo update') do
        options[:update] = false
      end

      parser.on('-B' '--no-build', 'skip static build') do
        options[:build] = false
      end

      parser.on('-d', '--dir DIR', 'alternate site directory') do |dir|
        dir = nil if %w{false nil ~}.include?(dir)  # TODO: better approach? 
        options[:dir] = dir
      end

      Console.compile(*parse(argv))
    end

    # Preview website. If `static` setting is set to `true` then
    # a preview of the static site will be served. Otherwise a live
    # preview will be served. The `--live` option can be used to
    # force a live preview even when `static` is `true`.
    #
    # Returns nothing.
    def preview(argv)
      if Console.settings.static && not argv.include?('--live')
        preview_static(argv)
      else
        preview_server(argv)
      end
    end

    # Preview static build.
    #
    #   TODO: Build if not already built.
    #
    # Returns nothing.
    def preview_static(argv)
      parser.banner = "Usage: smeagol-static-preview [OPTIONS]"

      #parser.on('-b', '--build', 'perform build before preview') do
      #  build = true
      #end

      lineno = 1
      parser.on("-e", "--eval LINE", "evaluate a LINE of code") { |line|
        eval line, TOPLEVEL_BINDING, "-e", lineno
        lineno += 1
      }

      parser.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") {
        options[:debug] = true
      }

      parser.on("-w", "--warn", "turn warnings on for your script") {
        options[:warn] = true
      }

      parser.on("-I", "--include PATH",
              "specify $LOAD_PATH (may be used more than once)") { |path|
        (options[:include] ||= []).concat(path.split(":"))
      }

      parser.on("-r", "--require LIBRARY",
              "require the library, before executing your script") { |library|
        options[:require] = library
      }

      parser.on("-s", "--server SERVER", "serve using SERVER (thin/puma/webrick/mongrel)") { |s|
        options[:server] = s
      }

      parser.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") { |host|
        options[:Host] = host
      }

      parser.on("-p", "--port PORT", "use PORT (default: 9292)") { |port|
        options[:Port] = port
      }

      parser.on("-O", "--option NAME[=VALUE]", "pass VALUE to the server as option NAME. If no VALUE, sets it to true. Run '#{$0} -s SERVER -h' to get a list of options for SERVER") { |name|
        name, value = name.split('=', 2)
        value = true if value.nil?
        options[name.to_sym] = value
      }

      parser.on("-E", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
        options[:environment] = e
      }

      parser.on("-D", "--daemonize", "run daemonized in the background") { |d|
        options[:daemonize] = d ? true : false
      }

      parser.on("-P", "--pid FILE", "file to store PID (default: rack.pid)") { |f|
        options[:pid] = ::File.expand_path(f)
      }

      #parser.on_tail("-h", "-?", "--help", "Show this message") do
      #  puts parser
      #  #puts handler_parser(options)
      #  exit
      #end

      #parser.parse!(argv)
      #rack_parser = ::Rack::Server::Options.new(options)
      #rack_options = rack_parser.parse!(argv)
      #@options = rack_options.merge(smeagol_options)

      $stderr.puts "Starting static preview..."

      Console.static_preview(*parse(argv))
    end

    #
    # Serve present Gollum wiki via Smeagol frontend.
    #
    def preview_server(argv)
      parser.banner = "Usage: smeagol-preview [OPTIONS]\n\n"

      parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
        options[:port] = port.to_i
      end

      parser.on('--[no-]cache', 'Enables page caching.') do |flag|
        options[:cache] = flag
      end

      parser.on('--mount-path', 'Serve website from this base path.') do |path|
        options[:mount_path] = path
      end

      #parser.on('--auto-update', 'Updates the repository on a daily basis.') do |flag|
      #  options[:auto_update] = flag
      #end

      #parser.on('--secret [KEY]', 'Specifies the secret key used to update.') do |str|
      #  options[:secret] = str
      #end

      repository = {}
      repository[:path]   = argv.first || Dir.pwd
      #repository[:cname] = options[:cname]  if options[:cname]
      repository[:secret] = options[:secret] if options[:secret]

      options[:repositories] = [repository]

      $stderr.puts "Starting live preview..."

      Console.serve(*parse(argv))
    end

    # Serve all Gollum repositories as setup in Smeagol config.
    # This can be used to serve sites in production. It makes use
    # of cnames to serve multiple sites via a single domain.
    #
    # Returns nothing.
    def serve(argv)
      config_file = nil

      parser.banner = "usage: smeagol-serve [OPTIONS] [PATH]\n\n"

      parser.on('-c', '--config [PATH]', 'Load config file instead of default.') do |path|
        options[:config_file] = path
      end

      parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
        options[:port] = port.to_i
      end

      parser.on('--[no-]cache', 'Enables page caching.') do |flag|
        options[:cache] = flag
      end

      parser.on('--mount-path', 'Serve website from this base path.') do |path|
        options[:mount_path] = path
      end

      parser.on('--auto-update', 'Updates the repository on a daily basis.') do |flag|
        options[:auto_update] = flag
      end

      parser.on('--secret [KEY]', 'Specifies the secret key, if needed to update.') do |str|
        options[:secret] = str
      end

      Console.serve(*parse(argv))
    end

    # Update wiki repo and update/clone site repo, if designated
    # in settings.
    #
    # Returns nothing.
    def update(argv)
      parser.banner = "Usage: smeagol update [OPTIONS]\n\n"

      parser.on('-d', '--dir DIR', 'alternate static site directory') do |dir|
        dir = nil if %w{false nil ~}.include?(dir)  # TODO: better approach? 
        options[:site_dir] = dir
      end

      Console.update(*parse(argv))
    end

  private

    # Options.
    #
    # Returns Hash of options.
    def options
      @options ||= {}
    end

    # Read command line options into `options` hash.
    #
    # Returns Array of arguments and options.
    def parse(argv)
      begin
        parser.parse!(argv)
      rescue ::OptionParser::InvalidOption
        puts "smeagol: #{$!.message}"
        puts "smeagol: try 'smeagol --help' for more information"
        exit 1
      end
      return *(argv + [options])
    end

    # Create and cache option parser.
    #
    # Returns OptionParser.
    def parser
      @parser ||= (
        parser = ::OptionParser.new
        parser.on_tail('--debug', 'Turn on $DEBUG mode.') do
          $DEBUG = true
        end
        parser.on_tail('-v', '--version', 'Display current version.') do
          puts "Smeagol #{Smeagol::VERSION}"
          exit 0
        end
        parser.on_tail('-h', '-?', '--help', 'Display this help screen.') do
          puts parser
          exit 0
        end
        parser
      )
    end

  end

end
