module Smeagol
  module Views
    class Base < ::Mustache
      # Initializes a new mustache view template data object.
      #
      # wiki - The wiki that this view represents.
      #
      # Returns a new view object.
      def initialize(wiki, version='master')
        @wiki    = wiki
        @version = version || 'master'

        dir = File.join(wiki.path, '_smeagol', 'layouts')
        if File.directory?(dir)
          self.class.template_path = dir 
        else
          self.class.template_path = File.join(File.dirname(__FILE__), '..', 'templates', 'layouts')
        end
      end
      
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
            Smeagol::Views::Post.new(page)
          end
        )
      end

      #  P R O T E C T E D
      
      #protected
      
      # The Gollum::Wiki that this view represents.
      attr_reader :wiki
      
      # The tagged version that is being viewed.
      attr_reader :version
      

      #  P R I V A T E

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

    end
  end
end
