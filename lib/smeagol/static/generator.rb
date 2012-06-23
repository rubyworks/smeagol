require 'mustache'
require 'json'
require 'smeagol/helpers/rss'

module Smeagol
  module Static
    class Generator

      #
      def initialize(wiki)
        @wiki = wiki

        #@pages     = {}
        #@directory = []
      end

      #
      def build(directory)
        puts "Building #{directory} ..."

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

        view_pages.each do |page|
          href = page.static_href
          path = File.join(@dir, href)
          mkdir_p(File.dirname(path))
          puts "write #{path}"
          File.open(path, 'w') do |f|
            html = Mustache.render(template(page), page)  # page.gollum_page)
            f.write(html)
          end
        end

        @wiki.files.each do |file|
          next if file == 'smeagol.yml'
          href = file.path #static_href
          path = File.join(@dir, href)
          mkdir_p(File.dirname(path))
          puts "write #{path}"
          File.open(path, 'w') do |f|
            f.write(file.raw_data)
          end
        end

        save_rss if @wiki.settings.rss

        save_toc
      end

    private

      #
      def view_pages
        @view_pages ||= \
          @wiki.pages.map do |page|
            Smeagol::Views::Page.new(page)
          end
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
        file = File.join(@dir, 'toc.json')
        File.open(file, 'w') do |f|
          f << toc_json.to_json
        end
      end

      #
      def template(page)
        if page.post?
          post_template
        else
          page_template
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
        json = {}
        view_pages.each do |page|
          data = {}
          data['title']   = page.page_title
          data['name']    = page.name
          data['href']    = page.static_href
          data['date']    = page.post_date if page.post_date
          data['author']  = page.author
          data['summary'] = page.summary
          json[page.name] = data
        end
        json
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
