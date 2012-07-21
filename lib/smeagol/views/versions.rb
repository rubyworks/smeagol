module Smeagol
  module Views
    class Versions < Base
      # Initializes a new mustache view template data object.
      #
      # master - Master controller, which creates all the views.
      #
      # Returns a new page object.
      def initialize(master)
        @master  = master
        @wiki    = master.wiki

        setup_template_path
      end

      # Public: The HTML formatted content of the page.
      def content
        html = "<a href=\"/\">Current</a><br/>"
        wiki.repo.tags.each do |tag|
          href = tag.name.start_with?('v') ? "/#{tag.name}" : "/v#{tag.name}"
          html << "<a href=\"#{href}\">#{tag.name}</a><br/>"
        end
        html
      end

      # Public: The URL of the project source code. This is set in the settings
      # file.
      def source_url
        settings.source_url
      end

      # TODO: Allow customization ?
      def layout
        IO.read(LIBDIR + "/templates/layouts/versions.mustache")
      end

    end
  end
end
