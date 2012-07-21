module Smeagol

  # Smeagol::CLI module is a function module that provide
  # all command line interfaces.
  #
  module CLI

    extend self

    #
    # Initialize Gollum wiki site for use with Smeagol.
    #
    def init(argv)
      parser.banner = "usage: smeagol-init [OPTIONS] [WIKI-URI]\n"

      parser.on('-t', '--title [TITLE]') do |title|
        options[:title] = title
      end

      parser.on('-i', '--index [PAGE]') do |page_name|
        options[:index] = page_name
      end

      # TODO: support more settings options for creating setup

      Console.init(*parse(argv))
    end

    #
    # Preview current Gollum wiki.
    #
    def preview(argv)
      parser.banner = "Usage: smeagol-preview [OPTIONS]\n"

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

      $stderr.puts "Starting preview..."

      Console.preview(*parse(argv))
    end

    #
    # Serve all Gollum repositories as setup in Deagol config file.
    # This can be used to serve sites in production. It makes use
    # of cnames to serve multiple sites via a single service.
    #
    def serve(argv)
      config_file = nil

      parser.banner = "usage: smeagol-serve [OPTIONS]\n"

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

    #
    # Update wiki repo and update/clone site repo, if designated
    # in settings.
    #
    def update(argv)
      parser.banner = "Usage: smeagol-update [OPTIONS]\n"

      parser.on('-a', '--all', 'Update all configured repos.') do
        options[:all] = true
      end

      #parser.on('-s', '--site', 'Also update site directories, if applicable.') do
      #  options[:site] = true
      #end

      Console.update(*parse(argv))
    end

  private

    #
    # Command line options.
    #
    # Returns the command line options. [Hash]
    #
    def options
      @options ||= {}
    end

    #
    # Read command line options into `options` hash.
    #
    # Returns arguments and options. [Array]
    #
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

    #
    # Create and cache option parser.
    #
    # Returns option parser instance. [OptionParser]
    #
    def parser
      @parser ||= (
        parser = ::OptionParser.new
        parser.on_tail('--quiet', 'Turn on $QUIET mode.') do
          $QUIET = true
        end
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
