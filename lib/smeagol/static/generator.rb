module Smeagol
  module Static
    class Generator

      #
      def initialize(wiki)
        @wiki       = wiki
        @controller = Controller.new(wiki)
        @fileutils  = $DEBUG ? FileUtils::Verbose : FileUtils
      end

      # Instance of Gollum::Wiki.
      attr_reader :wiki

      # Instance of Smeagol::Controller.
      attr_reader :controller

      #
      def views
        controller.views
      end

      #
      def settings
        controller.settings
      end

      #
      def build(directory)
        #puts "Building #{directory} ..."
        @dir = directory
        save
      end

      #
      def save
        #fileutils.mkdir(@dir) unless File.exist?(@dir)

        save_smeagol
        save_rss if settings.rss
        save_toc

        views.each do |view|
          content = controller.render_view(view)
          path = ::File.join(@dir, view.href)
          write(path, content)
        end

        #pages.each do |page|
        #  #html = Mustache.render(template(page, :page), page)  # page.gollum_page)
        #  view, content = controller.render_page(page)
        #  path = File.join(@dir, view.href)
        #  write(path, content)
        #end

        #posts.each do |post|
        #  #html = Mustache.render(template(post, :post), post)  # page.gollum_page)
        #  view, content = controller.render_post(post)
        #  path = File.join(@dir, view.href)
        #  write(path, content)         
        #end

        #files.each do |file|
        #  view, content = controller.render_file(file)
        #  path = File.join(@dir, view.href)
        #  write(path, content)
        #end

        #assets.each do |file|
        #  #next if file == 'smeagol.yml'
        #  content = file.raw_data
        #  path    = File.join(@dir, file.path)
        #  write(path, content)
        #end
      end

    private

      # Write content to given path.
      def write(path, content)
        mkdir_p(File.dirname(path))
        puts "write: #{path}"  # log instead?
        File.open(path, 'w') do |f|
          f.write(content.to_s)
        end
      end

=begin
      # Collect list of pages.
      #
      def pages
        @pages ||= (
          filter(@wiki.pages){ |p| !p.post? } #.map do |page|
            #Smeagol::Views::Page.new(page)
          #end
        )
      end

      # Collect list of posts.
      #
      def posts
        @posts ||= (
          filter(@wiki.pages){ |p| p.post? } #.map do |page|
          #  Smeagol::Views::Post.new(page)
          #end
        )
      end

      # Collect list of non-page files to be rendered.
      #
      def files
        @files ||= (
          filter(@wiki.files){ |f| f.extname == '.mustache' } #.map do |file|
          #  Smeagol::Views::Template.new(file)
          #end
        )
      end

      # Collect list of raw asset files.
      #
      def assets
        @assets ||= (
          filter(@wiki.files){ |f| f.extname != '.mustache' } 
        )
      end

      # Filter files according to settings `include` and `exclude` fields.
      # Selection block can be given to further filter the list.
      #
      # paths - Array of paths to be filtered.
      #
      # Returns [Array<String>].
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
        result = result.select(&selection) if selection
        result
      end
=end

      # Copy smeagol's default public files to static site.
      # These files are put in a separate `smeagol` directory
      # to avoid name clashes with wiki files.
      def save_smeagol
        src = File.dirname(__FILE__) + '/../public/assets'
        #dst = File.join(@dir, 'smeagol')  # TODO: move to assets/smeagol ?
        fileutils.mkdir_p(@dir) unless File.directory?(@dir)
        fileutils.cp_r(src, @dir) 
      end

      # Save tab le of contents.
      def save_toc
        toc  = TOC.new(@wiki)
        file = File.join(@dir, 'toc.json')
        write(file, toc)
      end

      # Generate RSS feed from post pages and save.
      def save_rss
        rss = RSS.new(@wiki)
        file = File.join(@dir, 'rss.xml')
        write(file, rss)
      end

      ## For static sites we cannot depend on the web server to default a link
      ## to a directory to the index.html file within it. So we need to append
      ## index.html to any href links for which we have wiki pages.
      ## This is not a prefect solution, but there may not be a better one.
      ##
      #def index_directory_hrefs(html)
      #  html.gsub(/href=\"(.*)\"/) do |match|
      #    link = "#{$1}/index.html"
      #    if @pages[link] #if File.directory?(File.join(current_directory, $1))
      #      "href=\"#{link}\""
      #    else
      #      match  # no change
      #    end
      #  end
      # end

      # Access to FileUtils.
      #
      def fileutils
        @fileutils
      end

      #
      def mkdir_p(dir_name)
        fileutils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end

    end

  end

end
