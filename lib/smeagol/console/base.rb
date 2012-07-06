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

    end

  end

end
