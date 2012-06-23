module Smeagol

  module Console

    class Serve < Base

      def initialize(options={})
        @git           = options[:git]
        @port          = options[:port]
        @repositories  = options[:repositories]
        @auto_update   = options[:auto_update]
        @cache_enabled = options[:cache_enabled]
        @mount_path    = options[:mount_path]
      end

      #
      # Run the web server.
      #
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

      #
      # Catch signals.
      #
      def catch_signals
        Signal.trap('TERM') do
          Process.kill('KILL', 0)
        end
      end

      #
      # Show repositories being served
      #
      def show_repository
        $stderr.puts "\n  Now serving:"
        @repositories.each do |repository|
          $stderr.puts "  #{repository[:path]} (#{repository[:cname]})"
        end
        $stderr.puts "\n"
      end

      #
      # Run the auto update process.
      #
      def auto_update
        if @git && @auto_update
          Thread.new do
            while true do
              sleep 86400
              @repositories.each do |repository|
                wiki = Smeagol::Wiki.new(@repository[:path])
                wiki.update(@git)
              end
            end
          end
        end
      end

      #
      # Clear the caches.
      #
      def clear_caches
        @repositories.each do |repository|
          Smeagol::Cache.new(Gollum::Wiki.new(repository[:path])).clear()
        end
      end

    end

  end

end
