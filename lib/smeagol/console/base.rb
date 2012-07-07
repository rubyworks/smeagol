module Smeagol

  module Console

    # Base class for all console utilies.
    #
    class Base

      # Convenince method to run console command.
      def self.run(*args)
        new(*args).call
      end

      #
      def initialize(options={})
        @options  = options  # in case they need to be reused
        @wiki_dir = options[:wiki_dir] || Dir.pwd
      end

      #
      attr_reader :wiki_dir

      # Get and cache Wiki object.
      #
      # Returns Smeagol::Wiki instance.
      def wiki
        @wiki ||= Smeagol::Wiki.new(wiki_dir)
      end

      # Local wiki settings.
      #
      # Returns Smeagol::Settings instance.
      def settings
        @settings ||= Settings.load(wiki_dir)
      end

      # Git executable.
      def git
        Smeagol.git
      end

      # TODO: Maybe add a random number to be safe.
      #
      # Return String path to system temprorary directory.
      def tmpdir(base=nil)
        if base
          ::File.join(Dir.tmpdir, 'smeagol', base)
        else
          ::File.join(Dir.tmpdir, 'smeagol', Time.now.year.to_s)
        end
      end

    end

  end

end
