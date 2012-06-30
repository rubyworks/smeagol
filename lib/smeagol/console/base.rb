module Smeagol

  module Console

    class Base

      # Convenince method to run console command.
      def self.run(*args)
        new(*args).call
      end

      # Get and cache Wiki object.
      #
      # Returns Smeagol::Wiki instance.
      def wiki(dir=Dir.pwd)
        @wiki ||= Smeagol::Wiki.new(dir)
      end

      # Local wiki settings.
      #
      # Returns Smeagol::Settings instance.
      def settings
        @settings ||= Settings.load
      end

      # Locates the git binary in common places in the file system.
      #
      # TODO: Can we use shell.rb for this?
      #
      # Returns String path to git executable.
      def get_git
        git = nil

        ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/opt/local/bin'].each do |path|
          file = "#{path}/git"
          git = file if File.executable?(file)
          break if git
        end
      
        # Alert user that updates are unavailable if git is not found
        if git.nil? || !File.executable?(git)
          warn "warning: git executable could not be found."
        else
          $stderr.puts "git found: #{git}" if $DEBUG
        end

        return git
      end

    end

  end

end
