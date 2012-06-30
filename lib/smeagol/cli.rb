require 'optparse'

module Smeagol

  module CLI
    extend self

    # Initialize Gollum wiki site for use with Smeagol.
    #
    def init(argv)
      parser.banner = "usage: smeagol init [OPTIONS] [WIKI-URI]"

      #opts.on('-b', '--build-dir [DIRECTORY]') do |dir|
      #  options[:build_dir] = dir
      #end

      parser.on('--git [GIT]', 'Path to Git binary.') do |path|
        options['git'] = path
      end

      # TODO: support more settings options for creating setup

      Console.init(*parse(argv))
    end

    # Run Smeagol server. If `argv` contains `-S` or `--static`,
    # then a preview of the static files in the build directory
    # will be served instead.
    #
    # Returns nothing.
    def preview(argv)
      if argv.delete('-S') || argv.delete('--static')
        preview_static(argv)
      else
        preview_dynamic(argv)
      end
    end

    # Preview static build.
    #
    #   TODO: Somehow handle options prior to racks handling.
    #         I hope we donn't have to delegate all of thme
    #
    #   TODO: Build if not already built.
    #
    def preview_static(argv)
      parser = ::Rack::Server::Options.new

      #parser.banner = "usage: smeagol serve --static [OPTIONS]"

      #parser.on('-b', '--build', 'perform build before preview') do
      #  options[:build] = true
      #end

      @options = parser.parse!(argv)

      Console.preview(options)
    end

    #
    # Serve Gollum wiki via Smeagol frontend.
    #
    def preview_dynamic(argv)
      config_file = nil

      parser.banner = "usage: smeagol [OPTIONS] [PATH]\n\n"

      # this is a dummy option for help b/c of static preview
      parser.on('-S', '--static', 'Preview static build.') do
        #options[:static] = true
      end

      parser.on('-c', '--config [PATH]', 'Loads this config file instead of default.') do |path|
        config_file = path
      end

      parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
        options[:port] = port.to_i
      end

      #parser.on('--auto-update', 'Updates the repository on a daily basis.') do |flag|
      #  options[:auto_update] = flag
      #end

      parser.on('--[no-]cache', 'Enables page caching.') do |flag|
        options[:cache] = flag
      end

      parser.on('--secret [KEY]', 'Specifies the secret key used to update.') do |str|
        options[:secret] = str
      end

      parser.on('--mount-path', 'Serve website from this base path.') do |path|
        options[:mount_path] = path
      end

      parser.on('--git [GIT]', 'Path to Git binary.') do |path|
        options[:git] = path
      end

      repository = {}
      repository[:path]   = argv.first || Dir.pwd
      #repository[:cname] = options[:cname]  if options[:cname]
      repository[:secret] = options[:secret] if options[:secret]

      options[:repositories] = [repository]

      Console.serve(*parse(argv))
    end

    # Serve all Gollum repositories as setup in Smeagol config.
    # This can be used to serve sites in production. It makes use
    # cnames to serve multiple sites via a single domain.
    #
    # Returns nothing.
    def serve(argv)
      config_file = nil

      parser.banner = "usage: smeagol [OPTIONS] [PATH]\n\n"

      parser.on('-c', '--config [PATH]', 'Load config file instead of default.') do |path|
        options[:config_file] = path
      end

      parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
        options[:port] = port.to_i
      end

      parser.on('--auto-update', 'Updates the repository on a daily basis.') do |flag|
        options[:auto_update] = flag
      end

      parser.on('--[no-]cache', 'Enables page caching.') do |flag|
        options[:cache] = flag
      end

      parser.on('--mount-path', 'Serve website from this base path.') do |path|
        options[:mount_path] = path
      end

      parser.on('--secret [KEY]', 'Specifies the secret key used to update.') do |str|
        options[:secret] = str
      end

      parser.on('--git [GIT]', 'Path to Git binary.') do |path|
        options[:git] = path
      end

      Console.serve(*parse(argv))
    end

    # Build a static site.
    #
    # Returns nothing.
    def build(argv)
      parser.banner = "usage: smeagol build [OPTIONS]"

      parser.on('-t', '--tmp', 'use system temporary directory') do
        options[:use_tmp] = true
      end

      Console.build(*parse(argv))
    end

    # Use rsync to update the site directory from the build directory.
    #
    # Returns nothing.
    def sync(argv)
      parser.banner = "usage: smeagol sync [OPTIONS]"

      parser.on('-b', '--build', 'perform build before sync') do
        options[:build] = true
      end

      parser.on('-t', '--tmp', 'use system temporary directory') do
        options[:use_tmp] = true
      end

      parser.on('-s', '--site-dir [DIRECTORY]', 'sync to specifed directory') do |dir|
        options[:site_dir] = dir
      end

      Console.sync(*parse(argv))
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
        parser.on_tail('-v', '--version', 'Display current version.') do
          puts "Smeagol #{Smeagol::VERSION}"
          exit 0
        end
        parser.on_tail('-h', '--help', 'Display this help screen.') do
          puts self
          exit 0
        end
        parser
      )
    end

  end

end
