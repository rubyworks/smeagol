#require 'daemons'
require 'optparse'
require 'ostruct'
require 'smeagol'

module Smeagol
  # Creates a Serve command object and runs it.
  #
  # argv - command line arguments.
  #
  # Returns nothing.
  def self.serve(argv)
    Server.new(argv).run
  end

  class Server
    # Creates a Serve command object.
    #
    # argv - command line arguments.
    #
    # Returns a Smeagol::Commands::Serve object.
    def initialize(argv)
      @argv = argv
    end

    # Run the web server.
    def run
      catch_signals
      show_repository
      auto_update
      clear_caches

      Smeagol::App.set(:repositories, options.repositories)
      Smeagol::App.set(:git, options.git)
      Smeagol::App.set(:cache_enabled, options.cache_enabled)
      Smeagol::App.set(:mount_path, options.mount_path)
      Smeagol::App.run!(:port => options.port)
    end

    # Parse options.
    def options
      @options ||= Smeagol::OptionParser.parse(@argv)
    end

    # Catch signals.
    def catch_signals
      Signal.trap('TERM') do
        Process.kill('KILL', 0)
      end
    end

    # Show repositories being served
    def show_repository
      $stderr.puts "\n  Now serving:"
      options.repositories.each do |repository|
        $stderr.puts "  #{repository.path} (#{repository.cname})"
      end
      $stderr.puts "\n"
    end

    # Run the auto update process.
    def auto_update
      if options.git && options.auto_update
        Thread.new do
          while true do
            sleep 86400
            options.repositories.each do |repository|
              wiki = Smeagol::Wiki.new(repository.path)
              wiki.update(options.git)
            end
          end
        end
      end
    end

    # Clear the caches.
    def clear_caches
      options.repositories.each do |repository|
        Smeagol::Cache.new(Gollum::Wiki.new(repository.path)).clear()
      end
    end
  end
end
