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

    #
    # Serve present Gollum wiki via Smeagol frontend.
    #
    def preview(argv)
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

    # Update wiki repo and update/clone static site repo, if designated
    # by settings.
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
