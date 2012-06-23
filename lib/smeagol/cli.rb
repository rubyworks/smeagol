require 'optparse'

module Smeagol
  module CLI
    extend self

    #
    # Initialize Gollum wiki site for use with Smeagol.
    #
    def init(argv)
      parser.banner = "usage: smeagol-init [OPTIONS] [WIKI-URI]"

      #opts.on('-b', '--build-dir [DIRECTORY]') do |dir|
      #  options[:build_dir] = dir
      #end

      Console.init(*parse(argv))
    end

    #
    # Run Smeagol server.
    #
    def serve(argv)
      if argv.delete('-S') || argv.delete('--static')
        serve_static(argv)
      else
        serve_dynamic(argv)
      end
    end

    #
    # Serve static build.
    #
    # TODO: Build if not alread built.
    # TODO: build_dir option ?
    #
    def serve_static(argv)
      #parser.banner = "usage: smeagol-static-preview [OPTIONS]"

      #parser.on('-b', '--build-dir [DIRECTORY]') do |dir|
      #  options[:build_dir] = dir
      #end

      @options = ::Rack::Server::Options.new.parse!(argv)

      Console.preview(options)
    end
 
    #
    #
    #
    def serve_dynamic(argv)
      parser.banner = "usage: smeagol [OPTIONS] [PATH]\n\n"

      parser.on('-S', '--static', 'Preview static build.') do
        options['static'] = true
      end

      parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
        options['port'] = port.to_i
      end

      parser.on('--git [GIT]', 'Path to Git binary.') do |path|
        options['git'] = path
      end

      parser.on('-c', '--config [PATH]', '[DERECATED] Loads the config file (default /etc/smeagol/config.yml).') do |path|
        raise "-c/--config option no longer suppoerted. Use environment variable SMEAGOL_CONFIG instead."
      end

      parser.on('--auto-update', 'Updates the repository on a daily basis.') do |flag|
        options['auto_update'] = flag
      end

      parser.on('--[no-]cache', 'Enables page caching.') do |flag|
        options['cache_enabled'] = flag
      end

      parser.on('--secret [KEY]', 'Specifies the secret key used to update.') do |str|
        secret = str
      end

      # default options
      options[:port] = 4567
      options[:auto_update] = false
      options[:cache_enabled] = true
      options[:mount_path] = ''

      # load master config
      options.update(load_config)

      # parse command line options
      parse(argv)

      # attempt to find the git binary
      update_git_path(options)

      # append repositories from the command line.
      options[:repositories] ||= []
      if argv.first
        options[:repositories].unshift({:path => argv.first})
      end

      # set repository to present working directory if no paths specified.
      if options[:repositories].empty?
        options[:repositories] = [{:path => Dir.pwd}.to_ostruct]
      end

      # set secret on default repository if passed in.
      options[:repositories].first[:secret] = options[:secret] if options[:secret]

      Console.serve(options.to_ostruct)
    end

    #
    # Loads system wide configuration file.
    #
    # Returns a hash of options from the config file.
    #
    def load_config
      config = {}

      path = config_file

      if File.exists?(path)
        # Notify the user if the config file exists but is not readable.
        unless File.readable?(path)
          puts "Config file not readable: #{path}"
          exit
        end
        
        config = YAML.load(IO.read(path))
      end

      config = config.inject({}){ |h, (k,v)| h[k.to_sym] = v; h }

      return config
    end

    #
    # Locates the git binary in common places in the file system.
    #
    def update_git_path(options)
      if options['git'].nil?
        ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/opt/local/bin'].each do |path|
          file = "#{path}/git"
          options['git'] = file if File.executable?(file)
          break if options['git']
        end
      end

      # Alert user that updates are unavailable if git is not found
      if options['git'].nil? || !File.executable?(options['git'])
        puts "warning: git executable could not be found."
      else
        puts "git found: #{options['git']}" if $DEBUG
      end
    end

    #
    #
    #
    def build(argv)
      parser.banner = "usage: smeagol-static-build [OPTIONS]"

      parser.on('-b', '--build-dir [DIRECTORY]') do |dir|
        options[:build_dir] = dir
      end

      Console.build(*parse(argv))
    end

    #
    # Use rsync to update the site directory from the build directory.
    #
    def sync(argv)
      parser.banner = "usage: smeagol-static-sync [OPTIONS]"

      parser.on('-b', '--build-dir [DIRECTORY]') do |dir|
        options[:build_dir] = dir
      end

      parser.on('-s', '--site-dir [DIRECTORY]') do |dir|
        options[:site_dir] = dir
      end

      Console.sync(*parse(argv))
    end

  private

    #
    #
    #
    def options
      @options ||= {}
    end

    #
    # Read command line options into `options` hash.
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
    #
    #
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

    #
    #
    #
    def config_file
      file = ENV['SMEAGOL_CONFIG']
      if file
        puts "Cannot find configuration file: #{path}" unless File.exists?(path)
        puts "Cannot read configuration file: #{path}" unless File.readable?(path)
      end
      file || '/etc/smeagol/config.yml'
    end
  end

end

