module Smeagol

  module Views

    # The form view is used for generic files that are not
    # Gollum wiki pages. These are typically html or xml
    # files and they are rendered as mustache templates.
    #
    class Form < Base

      # The Gollum::File that this view represents. This is
      # the same as `#file`.
      alias form file

      # Public: Rendered content of the file.
      def content
        @content ||= Mustache.render(file.raw_data, self)
      end

      #
      def title
        filename  # TODO: better idea for form title?
      end
      alias_method :page_title, :title

      #
      #def content=(text)
      #  @content = text
      #end

      # Public: A flag stating that this is not the home file.
      def not_home?
        filename != "index.html"
      end

      # Public: static href, used when generating static site.
      def href
        dir  = ::File.dirname(file.path)
        ext  = ::File.extname(file.path)

        if dir != '.'
          ::File.join(dir, name.chomp(ext)) #file.path) 
        else
          if name == settings.index #|| 'Home'
            'index.html'
          else
            name.chomp(ext) #file.path
          end
        end
      end

    end #Form

  end

end
