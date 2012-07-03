module Smeagol

  module Views

    # Raw assest view.
    #
    class File < Base

      # Public: Rendered content of the file.
      def content
        @content ||= file.raw_data
      end

      # Public: The last author of this file.
      def author
        file.version.author.name
      end

      # Public: The last edit date of this file.
      def date
        file.version.authored_date.strftime("%B %d, %Y")
      end

      #
      def filename
        file.filename
      end

      #
      def name
        file.name
      end

      #
      def not_home?
        true
      end

      # Public: static href.
      def href
        file.path
      end

      # Raw assets have no layout.
      def layout
        nil
      end

    end

  end

end
