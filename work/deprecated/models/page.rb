module Smeagol

  module Models

    class Page < Base

      #
      def view(version='master')
        @view ||= Views::Page.new(wiki_file, version)
      end

      # Render page.
      #
      # version - Commit id, branch or tag.
      #
      # Returns [Array<Smeagol::Views::Post,String>].
      def render(version='master')
        super(version)
      end

      # Get page layout template.
      #
      def standard_layout
        local_layout(:page) || default_layout(:page)
      end

    end

  end

end
