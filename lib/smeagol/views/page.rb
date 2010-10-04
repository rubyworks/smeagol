module Smeagol
  module Views
    class Page < Mustache
      # Initializes a new page template data object.
      #
      # page - The individual wiki page that this view represents.
      #
      # Returns a new page object.
      def initialize(page)
        @page = page
      end
      
      # Public: The title of the wiki. This is set in the settings file.
      def wiki_title
        page.wiki.settings.title
      end
      
      # Public: The tagline for the wiki. This is set in the settings file.
      def tagline
        page.wiki.settings.tagline
      end
      
      # Public: The title of the page.
      def page_title
        page.title
      end
      
      # Public: The HTML formatted content of the page.
      def content
        page.formatted_data
      end

      # Public: The last author of this page.
      def author
        page.version.author.name
      end

      # Public: The last edit date of this page.
      def date
        page.version.authored_date.strftime("%B %d, %Y")
      end
      
      # Public: A flag stating that this is not the home page.
      def not_home?
        page.title != "Home"
      end
      
      # Public: The HTML menu generated from the settings.yml file.
      def menu_html
        menu = @page.wiki.settings.menu
        if !menu.nil?
          html = "<ul>\n"
          menu.each do |item|
            html << "<li><a href=\"#{item.href}\">#{item.title}</a></li>\n"
          end
          html << "</ul>\n"
        end
      end

      
      ##########################################################################
      #
      # Internal Methods
      #
      ##########################################################################
      
      private
      
      # The Gollum::Page that this view represents.
      attr_reader :page
    end
  end
end
