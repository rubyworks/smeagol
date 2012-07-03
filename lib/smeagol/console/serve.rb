module Smeagol

  module Console

    # Serve dynamic site.
    #
    class Serve < Base

      # Initialize new Serve console command.
      def initialize(config={})
        config = Smeagol::Config.new(config) unless Smeagol::Config === config

        @git           = config.git || get_git
        @port          = config.port
        @auto_update   = config.auto_update
        @cache_enabled = config.cache_enabled
        @mount_path    = config.mount_path
        @repositories  = config.repositories
      end

      # Path to git binary.
      attr_accessor :git

      # Port to use. Default is 4567.
      attr_accessor :port

      # List of repositories.
      attr :repositories

      # Run the Sinatra-based server.
      def call
        catch_signals
        show_repository
        auto_update
        clear_caches

        Smeagol::App.set(:repositories, @repositories)
        Smeagol::App.set(:git, @git)
        Smeagol::App.set(:cache_enabled, @cache_enabled)
        Smeagol::App.set(:mount_path, @mount_path)
        Smeagol::App.run!(:port => @port)
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
        $stderr.puts "\n  Now serving on port #{@port} at /#{@base_path}:"
        repositories.each do |repository|
          $stderr.puts "  * #{repository.path} (#{repository.cname})"
        end
        $stderr.puts "\n"
      end

      # Run the auto update process.
      #
      def auto_update
        if @git && @auto_update
          Thread.new do
            while true do
              sleep 86400
              @repositories.each do |repository|
                wiki = Smeagol::Wiki.new(repository.path)
                wiki.update(@git)
              end
            end
          end
        end
      end

      # Clear the caches.
      #
      # Returns nothing.
      def clear_caches
        @repositories.each do |repository|
          Smeagol::Cache.new(Gollum::Wiki.new(repository.path)).clear()
        end
      end

    end

  end

end
