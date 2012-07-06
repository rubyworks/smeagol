module Smeagol

  module Models

    class Base

      #
      def initialize(wiki_file, controller)
        @wiki_file  = wiki_file
        @controller = controller
      end

      # The Gollum::Page or Gollum::File instance.
      attr :wiki_file

      # Gollum::Wiki instance.
      def wiki
        @controller.wiki
      end

      #
      def settings
        @controller.settings
      end

      # Render post.
      #
      # version - Commit id, branch or tag.
      #
      # Returns [Array<Smeagol::Views::Post,String>].
      def render(version='master')
        view = view(version)

        if layout
          content = Mustache.render(layout, view)
        else
          content = view.content
        end

        return content
      end


      #
      def href(version='master')
        view(version).href
      end

    end

  end

end
