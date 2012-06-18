module Smeagol
  module Views
    class Page < Base
      # Initializes a new page template data object.
      #
      # page    - The individual wiki page that this view represents.
      # version - The tagged version of the page.
      #
      # Returns a new page object.
      def initialize(page, version='master')
        super(page.wiki, version)
        @page = page
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

      #
      def filename
        page.filename
      end

      #
      def name
        page.name
      end
      
      # Public: A flag stating that this is not the home page.
      def not_home?
        page.title != "Home"
      end

      # Public: static href, used when generating static site.
      #
      # TODO: Add slug support.
      def static_href
        dir  = File.dirname(page.path)
        name = page.filename_stripped
        if dir != '.'
          File.join(dir, name, 'index.html')
        else
          if name == 'Home'
            'index.html'
          else
            File.join(page.filename_stripped, 'index.html')
          end
        end
      end

      # If the name of the page begins with a date, then it is the "post date"
      # and is taken to be a blog entry, rather then an ordinary static page.
      def post_date
        if md = /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
          md[1]
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
