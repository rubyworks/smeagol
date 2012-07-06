module Smeagol

  module Models

    # Raw asset file.
    #
    class File < Base

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
        content = wiki_file.raw_data  # what about version ?
        return content
      end

      # Get generic layout template.
      #
      def standard_layout
        nil
      end

      # Drop the extension name for for mustache files.
      def layout_key
        nil
      end

      #
      def href(version='master')
        wiki_file.path #view(version).href
      end

    end

  end

end
