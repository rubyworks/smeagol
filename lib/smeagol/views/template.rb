module Smeagol
  module Views
    class Template < Base
      # Initializes a new generic template data object.
      #
      # file    - The individual wiki file that this view represents.
      # version - The tagged version of the file.
      #
      # Returns a new template object.
      def initialize(file, version='master')
        super(file.wiki, version)
        @file = file
      end

      # Public: The title of the file.
      #def title
      #  file.title
      #end

      # TODO: temporary alias
      #alias_method :file_title, :title

      # Public: The raw content of the file.
      def content
        @content ||= file.raw_data
      end

      #
      def content=(text)
        @content = text
      end

      #
      #def summary
      #  i = content.index('</p>')
      #  i ? content[0..i+3] : content  # any other way if no i, 5 line limit?
      #end

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

      # Public: A flag stating that this is not the home file.
      def not_home?
        filename != "index.html"
      end

      # Public: static href, used when generating static site.
      def href
        dir  = File.dirname(file.path)
        ext  = File.extname(file.path)

        if dir != '.'
          File.join(dir, name.chomp(ext)) #file.path) 
        else
          if name == @wiki.settings.index #|| 'Home'
            'index.html'
          else
            name.chomp(ext) #file.path
          end
        end
      end

=begin
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
=end

      ## If the name of the file begins with a date, then it is the "post date"
      ## and is taken to be a blog entry, rather then an ordinary static file.
      #def post_date
      #  if md = /^(\d\d\d\d-\d\d-\d\d)/.match(filename)
      #    md[1]
      #  end
      #end

      ##
      #def post?
      #  post_date
      #end
      
      #private
      
      # The Gollum::Page that this view represents.
      attr_reader :file

    end
  end
end
