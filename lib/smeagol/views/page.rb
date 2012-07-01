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
      def title
        page.title
      end

      # TODO: temporary alias
      alias_method :page_title, :title

      # Public: The HTML formatted content of the page.
      def content
        page.formatted_data
      end

      #
      def summary
        i = content.index('</p>')
        i ? content[0..i+3] : content  # any other way if no i, 5 line limit?
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
      def href
        dir  = File.dirname(page.path)
        name = slug(page.filename_stripped)
        ext  = File.extname(page.path)

        if dir != '.'
          File.join(dir, name, 'index.html')
        else
          if name == @wiki.settings.index #|| 'Home'
            'index.html'
          else
            File.join(name, 'index.html')
          end
        end
      end

      # Internal: Apply slug rules to name.
      #
      # TODO: Support configurable slugs.
      #
      # Returns [String] Sluggified name.
      def slug(name)
        if /^\d\d+\-/ =~ name
          dirs = [] 
          parts = name.split('-')
          while /^\d+$/ =~ parts.first
            dirs << parts.shift             
          end
          dirs << parts.join('-')
          dirs.join('/')
        else
          name
        end
      end

      # If the name of the page begins with a date, then it is the "post date"
      # and is taken to be a blog entry, rather then an ordinary static page.
      def post_date
        if md = /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
          md[1]
        end
      end

      #
      def post?
        post_date
      end
      
      #private
      
      # The Gollum::Page that this view represents.
      attr_reader :page

      #
      def layout
        @layout ||= (
          local_template(:page) || default_template(:post)
        )
      end

    end

  end

end
