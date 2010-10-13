module Smeagol
  module Views
    class Versions < Base
      # Public: The title of the wiki. This is set in the settings file.
      def wiki_title
        wiki.settings.title
      end
      
      # Public: The HTML formatted content of the page.
      def content
        html = "<a href=\"/\">Current</a><br/>"
        wiki.repo.tags.each do |tag|
          html << "<a href=\"/#{tag.name}\">#{tag.name}</a><br/>"
        end
        html
      end

      # Public: The URL of the project source code. This is set in the settings
      # file.
      def source_url
        wiki.settings.source_url
      end
    end
  end
end
