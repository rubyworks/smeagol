module Smeagol

  module Models

    # Special mustache files.
    #
    class Form < Base

      #
      def view(version='master')
        @view ||= Views::Template.new(wiki_file, version)
      end

      # Render mustache template file.
      #
      # version - Commit id, branch or tag.
      #
      # Returns [Array<Smeagol::Views::Template, String>].
      def render(version='master')
        view    = view(version)
        #content = Mustache.render(wiki_file.raw_data, view)
        content = Mustache.render(view.content, view)

        if layout && custom_layout? # no default
          view.content = content
          content = Mustache.render(layout, view)
        end

        return content
      end

      #
      def href(version='master')
        wiki_file.path #view(version).href
      end

    end

  end

end
