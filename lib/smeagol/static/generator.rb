require 'mustache'
require 'json'
require 'smeagol/helpers/rss'

module Smeagol
  module Static
    class Generator

      #
      def initialize(wiki)
        @wiki       = wiki
        @controller = Controller.new(wiki)

        #@pages     = {}
        #@directory = []
      end

      #
      attr_reader :wiki

      #
      attr_reader :controller

      #
      def build(directory)
        #puts "Building #{directory} ..."
        @dir = directory
        #directory_push(directory)
        #build_tree(@wiki.repo.tree)
        #directory_pop
        save
      end

      #
      def save
        #fileutils.mkdir(@dir) unless File.exist?(@dir)
        save_smeagol

        pages.each do |page|
          #html = Mustache.render(template(page, :page), page)  # page.gollum_page)
          view, content = controller.render_page(page)
          path = File.join(@dir, view.href)
          write(path, content)
        end

        posts.each do |post|
          #html = Mustache.render(template(post, :post), post)  # page.gollum_page)
          view, content = controller.render_post(post)
          path = File.join(@dir, view.href)
          write(path, content)         
        end

        files.each do |file|
          view, content = controller.render_file(file)
          path = File.join(@dir, view.href)
          write(path, content)
        end

        assets.each do |file|
          #next if file == 'smeagol.yml'
          content = file.raw_data
          path    = File.join(@dir, file.path)
          write(path, content)
        end

        save_rss if @wiki.settings.rss

        save_toc
      end

    private

      #
      def write(path, content)
        mkdir_p(File.dirname(path))
        puts "write: #{path}"  # log instead?
        File.open(path, 'w') do |f|
          f.write(content)
        end
      end

      # Collect list of viewable pages.
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

      # Collect list of raw assets.
      #
      def assets
        @assets ||= (
          filter(@wiki.files){ |f| f.extname != '.mustache' } 
        )
      end

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
        result = result.select(&selection) if selection
        result
      end

      # Copy smeagol's default public files to static site.
      # These files are put in a separate `smeagol` directory
      # to avoid name clashes with wiki files.
      def save_smeagol
        src = File.dirname(__FILE__) + '/../public/assets'
        #dst = File.join(@dir, 'smeagol')  # TODO: move to assets/smeagol ?
        fileutils.mkdir_p(@dir) unless File.directory?(@dir)
        fileutils.cp_r(src, @dir) 
      end

      #
      def save_toc
        toc  = TOC.new(@wiki)
        file = File.join(@dir, 'toc.json')
        File.open(file, 'w') do |f|
          f << toc.to_s
        end
      end

      #
      def template(page, type=nil)
        if name = @wiki.settings.layouts[page.path]
          local_template(name) || default_template(:page)
        else
          case type
          when :page
            page_template
          when :post
            post_template
          else
            generic_template
          end
        end
      end

      #
      def page_template
        @page_template ||= (
          local_template(:page) || default_template(:page)
        )
      end

      #
      def post_template
        @post_template ||= (
          local_template(:post) || local_template(:page) || default_template(:post)
        )
      end

      # TODO: Use separate template than page's.
      def generic_template
        @generic_template ||= (
          local_template(:page) || default_template(:page)
        )
      end

      #
      def local_template(type)
        file = "#{@wiki.path}/_smeagol/layouts/#{type}.mustache"
        if File.exists?(file)
          IO.read(file)
        else
          nil
        end
      end

      #
      def default_template(type)
        IO.read(File.join(File.dirname(__FILE__), "../templates/layouts/#{type}.mustache"))
      end

      #
      def toc_json
      end

      # Internal: Static URL for href.
      def static_href(page)
        dir  = File.dirname(page.path)
        name = slug(page.filename_stripped)
        ext  = File.extname(page.path)

        if dir != '.'
          File.join(dir, name, 'index.html')
        else
          if name == wiki.settings.index #|| 'Home'
            'index.html'
          else
            File.join(name, 'index.html')
          end
        end
      end

=begin
    #
    def current_directory
      @directory.last
    end

    #
    def directory_pop
      @directory.pop()
    end

    #
    def directory_push(dir)
      if @directory.empty?
        @directory << dir
      else
        @directory << "#{current_directory}/#{dir}"
      end

      #if not File.directory?(current_directory)
      #  fileutils.mkdir(current_directory) unless File.directory?(current_directory)
      #end
    end
=end

=begin
    #
    def build_tree(tree)
      tree.contents.each do |item|
        if item.class == Grit::Tree
          directory_push(item.name)
          build_tree(item)
          directory_pop()
        else
          build_blob(item)
        end
      end
    end
=end

=begin
    #
    def build_tree
      @wiki.pages().each do |page|
        #next if ::File.extname(page.filename) == '.yml'
        #next if ::File.extname(page.filename) == '.mustache'
        view_page = Smeagol::Views::Page.new(page)
        @pages[view_page.static_href] = view_page
      end
      @wiki.files().each do |file|
        #next if ::File.extname(file.filename) == '.yml'
        #next if ::File.extname(file.filename) == '.mustache'
        #view_page = Smeagol::Views::Page.new(page)
        @pages[view_page.static_href] = file
      end
    end

    #
    def build_blob(blob)
      return if blob.name == 'settings.yml'  # TODO: change this to `smeagol.yml`?
      return if File.extname(blob.name) == '.mustache'

      if name = @wiki.page_class.valid_page_name?(blob.name)
        page = @wiki.page(name)
        view = Smeagol::Views::Page.new(page)

        if name != 'Home'
          directory_push(name)
        end

        @pages[view.static_href] = view

        #@rss.add(name, view)  # TODO: remove

        if name != 'Home'
          directory_pop
        end
      else
        # TODO: why can't we get the path from the blob?
        href = File.join(current_directory, blob.name).sub(@dir, '')
        @pages[href] = blob
      end
    end
=end

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
      def mkdir_p(dir_name)
        fileutils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end

=begin
    #
    # For static sites we cannot depend on the web server to default a link
    # to a directory to the index.html file within it. So we need to append
    # index.html to any href links for which we have wiki pages.
    # This is not a prefect solution, but there may not be a better one.
    #
    def index_directory_hrefs(html)
      html.gsub(/href=\"(.*)\"/) do |match|
        link = "#{$1}/index.html"
        if @pages[link] #if File.directory?(File.join(current_directory, $1))
          "href=\"#{link}\""
        else
          match  # no change
        end
      end
    end
=end

      #
      # Generate RSS feed from post pages and save.
      #
      def save_rss
        rss = RSS.new(@wiki, view_pages)

        rss_file = File.join(@dir, 'rss.xml')

        puts "write #{rss_file}"

        File.open(rss_file, 'w') do |f|
          f.write(rss.to_s)
        end
      end

      #
      # Access to FileUtils.
      #
      def fileutils
        FileUtils::Verbose
      end

    end
  end
end
