module Smeagol
  class OptionParser
    # Parses the command line options.
    #
    # args - The arguments to parse. Typically use `ARGV`.
    #
    # Returns an OpenStruct of the options.
    def self.parse(args)
      # Set parse options
      secret = nil
      options = {}
      parser = ::OptionParser.new do |parser|
        parser.banner = 'usage: smeagol [OPTIONS] [PATH]\n\n'

        parser.on('--port [PORT]', 'Bind port (default 4567).') do |port|
          options['port'] = port.to_i
        end

        parser.on('--git [GIT]', 'Path to Git binary.') do |path|
          options['git'] = path
        end

        parser.on('-c', '--config [PATH]', 'Loads the config file. (default /etc/smeagol/config.yml)') do |path|
          puts "Cannot find configuration file: #{path}" unless File.exists?(path)
          puts "Cannot read configuration file: #{path}" unless File.readable?(path)
          options['config_path'] = path
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

        parser.on('-v', '--version', 'Display current version.') do
          puts "Smeagol #{Smeagol::VERSION}"
          exit 0
        end
      end

      # Read command line options into `options` hash
      begin
        parser.parse!
      rescue ::OptionParser::InvalidOption
        puts "smeagol: #{$!.message}"
        puts "smeagol: try 'smeagol --help' for more information"
        exit
      end





      # Load config
      config_path = options['config_path'] || '/etc/smeagol/config.yml'
      config = load_config(config_path)
      opts = default_options.merge(config).merge(options)
      opts = opts.to_ostruct()

      # Attempt to find the git binary
      update_git_path(opts)

      # Append repositories from the command line.
      opts.repositories ||= []
      if !args.first.nil?
        opts.repositories.unshift({:path => args.first}.to_ostruct)
      end
      
      # Set repository to present working directory if no paths specified.
      if opts.repositories.empty?
        opts.repositories = [{:path => Dir.pwd}.to_ostruct]
      end
      
      # Set secret on default repository if passed in.
      opts.repositories.first.secret = secret unless secret.nil?
      
      # Merge all options
      return opts
    end


    ###########################################################################
    #
    # Private Methods
    #
    ###########################################################################
    
    private

    # The default options for Smeagol.
    def self.default_options
      options = Hash.new
      options['port'] = 4567
      options['auto_update'] = false
      options['cache_enabled'] = true
      options['mount_path'] = ''
      options
    end
    
    # Loads a configuration file.
    #
    # Returns a hash of options from the config file.
    def self.load_config(path)
      config = {}
      
      if File.exists?(path)
        # Notify the user if the config file exists but is not readable.
        if !File.readable?(path)
          puts "Config file not readable: #{path}"
          exit
        end
        
        config = YAML.load(IO.read(path))
      end

      return config
    end

    # Locates the git binary in common places in the file system.
    def self.update_git_path(options)
      if options.git.nil?
        ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/opt/local/bin'].each do |path|
          file = "#{path}/git"
          options.git = file if File.executable?(file)
          break if options.git
        end
      end

      # Alert user that updates are unavailable if git is not found
      if options.git.nil? || !File.executable?(options.git)
        puts "warning: git executable could not be found."
      else
        puts "git found: #{options.git}"
      end
    end
  end
end
