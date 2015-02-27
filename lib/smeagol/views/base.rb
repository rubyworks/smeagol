module Smeagol

  module Views

    # Base class for all views.
    #
    # FAQ: Why aren't layouts versioned, i.e. pulled from the git repo
    #      like pages and posts? B/c we might want to look at content
    #      history, but that doesn't mean we want to look at it via
    #      an old layout.
    #
    class Base < ::Mustache
      # Initializes a new mustache view template data object.
      #
      # master  - Master controller, which creates all the views.
      # page    - The individual wiki page that this view represents.
      # version - The tagged version of the page.
      #
      # Returns a new page object.
      def initialize(master, file, version='master')
        @master  = master
        @file    = file
        @wiki    = file.wiki
        @version = version || 'master'

        self.template      = lookup_layout
        self.template_path = lookup_partials_path
      end

      # The Gollum::Wiki that this view represents.
      attr_reader :wiki
      
      # The tagged version that is being viewed.
      attr_reader :version

      # The Gollum::Page or Gollum::File that this view represents.
      attr_reader :file

      #
      def filename
        file.filename
      end

      # Page name.
      def name
        file.name
      end

      # Public: The title of the wiki. This is set in the settings file.
      def wiki_title
        settings.title
      end

      # Public: The tagline for the wiki. This is set in the settings file.
      def tagline
        settings.tagline
      end
      
      # Public: The URL of the project source code. This is set in the settings
      # file.
      def source_url
        settings.source_url
      end

      # Public: The Google Analytics tracking id from the settings file.
      def tracking_id
        settings.tracking_id
      end

      # Public: The HTML menu generated from the settings.yml file.
      def menu_html
        menu = wiki.settings.menu
        if !menu.nil?
          html = "<ul>\n"
          menu.each do |item|
            title, href = item['title'], item['href']
            if version != 'master' && item['href'].index('/') == 0
              prefix = version.start_with?('v') ? "/#{version}" : "/v#{version}"
            else
              prefix = ""
            end
            html << "<li class=\"minibutton\"><a href=\"#{prefix}#{href}\">#{title}</a></li>\n"
          end
          html << "</ul>\n"
        end
      end

      # Public: The HTML for the GitHub ribbon, if enabled. This can be set in
      # the settings file as `ribbon`.
      def ribbon_html
        if !source_url.nil? && !wiki.settings.ribbon.nil?
          name, pos = *wiki.settings.ribbon.split(' ')
          pos ||= 'right'
          
          html =  "<a href=\"#{source_url}\">"
          html << "<img style=\"position:absolute; top:0; #{pos}:0; border:0;\" src=\"#{ribbon_url(name, pos)}\" alt=\"Fork me on GitHub\"/>"
          html << "</a>"
        end
      end

      # Public: The string base path to prefix internal links.
      def base_path
        wiki.base_path
      end

      # List of posts.
      def posts
        @posts ||= @master.posts
        #@posts ||= (
        #  filter(@wiki.pages){ |p| p.post? }.map do |page|
        #    Smeagol::Views::Post.new(page, @version)
        #  end
        #)
      end

      #
      # Most recent 25 posts.
      #
      def recent_posts
        posts.reverse[0,25]
      end

=begin
      #
      def filter(paths, &selection)
        result = []
        paths.map do |file|
          unless settings.include.any?{ |x| File.fnmatch?(x, file.path) }
            next if file.path.split('/').any? do |x|
              x.start_with?('_') or x.start_with?('.')
            end
            next if settings.exclude.any?{ |x| File.fnmatch?(x, file.path) }
          end
          result << file
        end
        result = result.select(&selection)
        result
      end
=end

      HEXCOLORS = {
        'red' => 'aa0000', 'green' => '007200', 'darkblue' => '121621',
        'orange' => 'ff7600', 'gray' => '6d6d6d', 'white' => 'ffffff' 
      }

      #
      # Generates a github ribbon url.
      #
      def ribbon_url(name, pos)
        if hexcolor = HEXCOLORS[name]
          "http://s3.amazonaws.com/github/ribbons/forkme_#{pos}_#{name}_#{hexcolor}.png"
        else
          name
        end
      end

      # TODO: Actual slug support ?
      #def slug(page,blob)
      #  date = page.version.authored_date
      #  name = blob.name[name.index(/[A-Za-z]/)..-1]
      #
      #  if slug = @wiki.settings.slug
      #    slug = date.strftime(slug)
      #    slug = slug.sub(':name', name)
      #  else
      #    slug = name
      #  end
      #  slug
      #end

      #
      def post?
        false
      end

      # Support mathjax?
      def mathjax
        settings.mathjax
      end

      #
      def settings
        @master.settings
      end

      # Embedded metadata. 
      #
      # TODO: Can use file.metadata in future version of Gollum.
      #
      # Returns [Hash] of metadata.
      def metadata
        @metadata ||= (
          if md = /\<\!\-\-\-(.*?)\-{2,3}\>\s*\Z/m.match(content)
            YAML.load(md[1])
          else
            {}
          end
        )
      end

      # Get the layout template for the view.
      #def lookup_layout
      #  return nil if custom_layout? && !custom_layout
      #  custom_layout || standard_layout || default_layout
      #end

      ## Does the metadata specify a custom layout?
      #def custom_layout?
      #  metadata.key?('layout')        
      #end

      ## Value of layout metadata setting.
      #def custom_layout
      #  metadata['layout']
      #end

      #
      #
      #
      def layout
        lookup_layout
      end

      #
      # The Mustache template to use for rendering.
      #
      # Returns the content of the specified template file in the
      # wiki repository if it exists. Otherwise, it returns `nil`.
      #
      def lookup_layout
        return "{{{content}}}" if metadata.key?('layout') && !metadata['layout']

        name = metadata['layout'] || 'page'
        name = name + '.mustache' unless name.end_with?('.mustache')

        path = ::File.join('_layouts', name)
        dir  = ::File.join(wiki.path, ::File.dirname(file.path))

        layout_file = lookup_path(path, dir)

        if layout_file
          IO.read(layout_file)
        else
          default_layout
        end
      end

      #
      # Default template.
      #
      # Returns [String] The layout template included with the Smeagol package.
      #
      def default_layout
        @default_layout ||= (
          IO.read(LIBDIR + "/templates/layouts/page.mustache")
        )
      end

      #
      # Lookup the partials path. This starts in the directory
      # where the page is found, looking for `_includes` (by default),
      # and serches upwards for the same until it reaches the 
      # wiki's root directory. If not found it uses a fallback location
      # provided with the Smeagol package.
      #
      # Returns the directory of partials. [String]
      #
      def lookup_partials_path
        # See FAQ for Views::Base class
        dir  = ::File.join(wiki.path, ::File.dirname(file.path))
        path = ::File.join('_includes')

        partials_dir = lookup_path(path, dir)

        if partials_dir && ::File.directory?(partials_dir)
          partials_dir
        else
          ::File.join(LIBDIR, 'templates', 'includes')
        end
      end

      #
      def template_path=(path)
        self.class.template_path = path
      end

      #
      # Traverse upward in the directory tree looking for a
      # mathcing path. 
      #
      # path - Path to lookup.
      # dir  - Directory from which to start search.
      #
      def lookup_path(path, dir)
        dir  = ::File.expand_path(dir)
        top  = ::File.expand_path(wiki.path)
        home = ::File.expand_path('~')

        loop do
          found = Dir[::File.join(dir, path)].first
          return found if found
          return nil if dir == top
          return nil if dir == home  # just in case
          return nil if dir == '/'   # doubly so
          dir = ::File.dirname(dir)
        end
      end

    end

  end

end
