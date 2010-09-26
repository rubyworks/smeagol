module Smeagol
  class OptionParser
    # Parses the command line options.
    #
    # Returns an OpenStruct of the options.
    def self.parse(args)
      # Set default options
      options = OpenStruct.new
      options.port = 4567
      options.auto_update = false
      options.cache_enabled = true
      
      # Set parse options
      opts = ::OptionParser.new do |opts|
        opts.banner = 'usage: smeagol [OPTIONS] [PATH]\n\n'

        opts.on('--port [PORT]', 'Bind port (default 4567).') do |port|
          options.port = port.to_i
        end

        opts.on('--git [GIT]', 'Path to Git binary.') do |path|
          options.git = path
        end

        opts.on('--autoupdate', 'Updates the repository on a daily basis.') do |flag|
          options.auto_update = flag
        end

        opts.on('--[no-]cache', 'Enables page caching.') do |flag|
          options.cache_enabled = flag
        end

        opts.on('-v', '--version', 'Display current version.') do
          puts "Smeagol #{Smeagol::VERSION}"
          exit 0
        end
      end

      # Read command line options into `options` hash
      begin
        opts.parse!
      rescue ::OptionParser::InvalidOption
        puts "smeagol: #{$!.message}"
        puts "smeagol: try 'smeagol --help' for more information"
        exit
      end

      # Attempt to find the git binary
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

      # Set the path to the Gollum repository
      options.gollum_path = args[0] || Dir.pwd
      
      options
    end
  end
end