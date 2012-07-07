module Smeagol

  module Console

    # Serve dynamic site.
    #
    class Serve < Base

      # Initialize new Serve console command.
      def initialize(config={})
        @config = (
          if Smeagol::Config === config
            config
          else
            Smeagol::Config.new(config)
          end
        )

        #@port          = config.port
        #@auto_update   = config.auto_update
        #@cache_enabled = config.cache_enabled
        #@mount_path    = config.mount_path
        #@repositories  = config.repositories
        #@git           = Smeagol.git
      end

      # Returns Smeagol::Config instance.
      attr :config

      # Run the Sinatra-based server.
      def call
        catch_signals
        show_repository
        auto_update
        clear_caches

        Smeagol::App.set(:git, config.git)
        Smeagol::App.set(:repositories, config.repositories)
        Smeagol::App.set(:cache_enabled, config.cache_enabled)
        Smeagol::App.set(:mount_path, config.mount_path)
        Smeagol::App.run!(:port => config.port)
      end

      # Setup trap signals.
      #
      # Returns nothing.
      def catch_signals
        Signal.trap('TERM') do
          Process.kill('KILL', 0)
        end
      end

      # Show repositories being served
      #
      # Returns nothing.
      def show_repository
        $stderr.puts "\n  Now serving on port #{config.port} at /#{config.base_path}:"
        config.repositories.each do |repository|
          $stderr.puts "  * #{repository.path} (#{repository.cname})"
        end
        $stderr.puts "\n"
      end

      # Run the auto update process.
      #
      def auto_update
        if config.auto_update
          Thread.new do
            while true do
              sleep 86400
              config.repositories.each do |repository|
                #wiki = Smeagol::Wiki.new(repository.path)
                repository.update #(wiki, config.git)
              end
            end
          end
        end
      end

      # Clear the caches.
      #
      # Returns nothing.
      def clear_caches
        config.repositories.each do |repository|
          Smeagol::Cache.new(Gollum::Wiki.new(repository.path)).clear()
        end
      end

    end

  end

end
