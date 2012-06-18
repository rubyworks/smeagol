require 'mustache'
require 'smeagol/rss'

module Smeagol

  class Static

    #
    def initialize(wiki)
      @wiki = wiki

      @pages     = {}
      @directory = []
    end

    #
    def build(directory)
      puts "Building #{directory} ..."

      @dir = directory

      directory_push(directory)
      build_tree(@wiki.repo.tree)
      directory_pop
    end

    #
    def save
      #fileutils.mkdir(@dir) unless File.exist?(@dir)

      save_smeagol

      @pages.each do |href, page|
        file = File.join(@dir, href)
        dir_name = File.dirname(file)
        fileutils.mkdir_p(dir_name) unless File.directory?(dir_name)

        case page
        when Smeagol::Views::Page
          puts "write #{file}"
          File.open(file, 'w') do |f|
            html = Mustache.render(template, page)
            #html = index_directory_hrefs(html)
            f.write(html)
          end
        else  # blob
          #file_name = "#{current_directory}/#{blob.name}"
          puts "write #{file}"
          File.open(file, 'w') do |f|
            f.write(page.data)
          end
        end
      end

      save_rss
    end

  private

    #
    def template
      @template ||= (
        if File.exists?("#{@wiki.path}/page.mustache")
          IO.read("#{@wiki.path}/page.mustache")
        else
          IO.read(File.join(File.dirname(__FILE__), "templates/page.mustache"))
        end
      )
    end

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

    # Copy smeagol's default public files to static site.
    # These files are put in a separate `smeagol` directory
    # to avoid name clashes with wiki files.
    def save_smeagol
      src = File.dirname(__FILE__) + '/public/smeagol'
      #dst = File.join(@dir, 'smeagol')  # TODO: move to assets/smeagol ?
      fileutils.mkdir_p(@dir) unless File.directory?(@dir)
      fileutils.cp_r(src, @dir) 
    end

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
      rss = RSS.new(@wiki, @pages)

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
