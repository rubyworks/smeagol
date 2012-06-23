module Smeagol

  module Console

    class Base

      def self.run(*args)
        new(*args).call
      end

      #
      #
      #
      def wiki(dir=Dir.pwd)
        @wiki ||= Smeagol::Wiki.new(dir)
      end

      #
      # Local wiki settings.
      #
      def settings
        @settings ||= Settings.load
      end

    end

  end

end
