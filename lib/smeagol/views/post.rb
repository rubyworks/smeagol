module Smeagol

  module Views

    class Post < Page

      # The Gollum::Page that this view represents.
      # This is the same as `#page` and `#file`.
      alias post page

      # Public: static href, used when generating static site.
      def href
        dir  = ::File.dirname(page.path)
        name = slug(page.filename_stripped)
        ext  = ::File.extname(page.path)

        if dir != '.'
          ::File.join(dir, name, 'index.html')
        else
          if name == settings.index #|| 'Home'
            'index.html'
          else
            ::File.join(name, 'index.html')
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

    end

  end

end
