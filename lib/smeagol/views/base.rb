module Smeagol

  module Views

    class Base < ::Mustache
      # Initializes a new mustache view template data object.
      #
      # page    - The individual wiki page that this view represents.
      # version - The tagged version of the page.
      #
      # Returns a new page object.
      def initialize(file, version='master')
        @file    = file
        @wiki    = file.wiki
        @version = version || 'master'

        dir = ::File.join(wiki.path, '_layouts')
        if ::File.directory?(dir)
          self.class.template_path = dir 
        else
          self.class.template_path = ::File.join(::File.dirname(__FILE__), '..', 'templates', 'layouts')
        end
      end

      # The Gollum::Page or Gollum::File that this view represents.
      attr_reader :file

      # The Gollum::Wiki.
      attr_reader :wiki

      # Public: The title of the wiki. This is set in the settings file.
      def wiki_title
        wiki.settings.title
      end
      
      # Public: The tagline for the wiki. This is set in the settings file.
      def tagline
        wiki.settings.tagline
      end
      
      # Public: The URL of the project source code. This is set in the settings
      # file.
      def source_url
        wiki.settings.source_url
      end

      # Public: The Google Analytics tracking id from the settings file.
      def tracking_id
        wiki.settings.tracking_id
      end

      # Public: The HTML menu generated from the settings.yml file.
      def menu_html
        menu = wiki.settings.menu
        if !menu.nil?
          html = "<ul>\n"
          menu.each do |item|
            title, href = item['title'], item['href']
            if version != 'master' && item.href.index('/') == 0
              prefix = "/#{version}"
            else
              prefix = ""
            end
            html << "<li><a href=\"#{prefix}#{href}\">#{title}</a></li>\n"
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

      # Collect list of viewable pages.
      #
      # TODO: exlcusion/inclusion matching might need tweaking.
      #
      def posts
        @posts ||= (
          filter(@wiki.pages){ |p| p.post? }.map do |page|
            Smeagol::Views::Post.new(page, @version)
          end
        )
      end

      # Get the layout template for the view.
      def layout
        template = nil
        if name = wiki.settings.layouts[layout_key]
          template = local_layout(name)
        end
        if !template && !custom_layout? 
          template = standard_layout
        end
        template
      end

      #  P R O T E C T E D   M E T H O D S
      
      #protected
      
      # The Gollum::Wiki that this view represents.
      attr_reader :wiki
      
      # The tagged version that is being viewed.
      attr_reader :version
      

      #  P R I V A T E   M E T H O D S

      private

      #
      def filter(paths, &selection)
        result = []
        paths.map do |file|
          unless @wiki.settings.include.any?{ |x| File.fnmatch?(x, file.path) }
            next if file.path.split('/').any? do |x|
              x.start_with?('_') or x.start_with?('.')
            end
            next if @wiki.settings.exclude.any?{ |x| File.fnmatch?(x, file.path) }
          end
          result << file
        end
        result = result.select(&selection)
        result
      end

      # Generates the correct ribbon url
      def ribbon_url(name, pos)
        hexcolors = {'red' => 'aa0000', 'green' => '007200', 'darkblue' => '121621', 'orange' => 'ff7600', 'gray' => '6d6d6d', 'white' => 'ffffff'}
        if hexcolor = hexcolors[name]
          "http://s3.amazonaws.com/github/ribbons/forkme_#{pos}_#{name}_#{hexcolor}.png"
        else
          name
        end
      end

      # TODO: slug support
      def slug(page,blob)
        date = page.version.authored_date
        name = blob.name[name.index(/[A-Za-z]/)..-1]

        if slug = @wiki.settings.slug
          slug = date.strftime(slug)
          slug = slug.sub(':name', name)
        else
          slug = name
        end
        slug
      end

      #
      def standard_layout
        local_layout(:page) || default_layout(:page)
      end

      #
      def custom_layout?
        wiki.settings.layouts.key?(layout_key)
      end

      #
      def layout_key
        path
      end

      # The Mustache template to use for rendering.
      #
      # name - The name of the template to use.
      #
      # Returns the content of the specified template file in the
      # wiki repository if it exists. Otherwise, it returns `nil`.
      def local_layout(*names)
        names.each do |name|
          file = "#{@wiki.path}/_layouts/#{name}.mustache"
          if ::File.exists?(file)
            return IO.read(file)
          end
        end
        return nil
      end

      # Default template.
      #
      # name - The name of the template to use.
      #
      # Returns [String] The template included with the Smeagol package.
      def default_layout(name)
        IO.read(::File.join(::File.dirname(__FILE__), "../templates/layouts/#{name}.mustache"))
      end

      #
      def post?
        false
      end

    end

  end

end
