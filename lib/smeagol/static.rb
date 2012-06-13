require 'mustache'
require 'smeagol/rss'

module Smeagol

  class Static
    #
    def initialize(wiki)
      @wiki = wiki
      @rss  = RSS.new(@wiki)

      @directory = []
    end

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

      if not File.directory?(current_directory)
        fileutils.mkdir(current_directory) unless File.directory?(current_directory)
      end
    end

    # Copy smeagol's default public files to static site.
    # These files are put in a separate `smeagol` directory
    # to avoid name clashes with wiki files.
    def build_smeagol
      dir = File.dirname(__FILE__) + '/public/smeagol'
      fileutils.cp_r(dir, current_directory)
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
      return if blob.name == 'settings.yml'  # TODO: probably should change this to `smeagol.yml`.
      return if File.extname(blob.name) == '.mustache'

      if name = @wiki.page_class.valid_page_name?(blob.name)
        page = @wiki.page(name)

        if name != 'Home'
          directory_push(name)
        end

        href = "#{current_directory}/index.html"

        puts "write #{href}"

        File.open(href, 'w') do |f|
          view = Smeagol::Views::Page.new(page)
          html = Mustache.render(template, view)
          html = index_directory_hrefs(html)
          f.write(html)
        end

        @rss.add(name, href, page)

        if name != 'Home'
          directory_pop
        end
      else
        file_name = "#{current_directory}/#{blob.name}"
        dir_name  = File.dirname(file_name)
        fileutils.mkdir_p(dir_name) unless File.directory?(dir_name)

        puts "write #{file_name}"
        File.open(file_name, 'w') do |f|
          f.write(blob.data)
        end
      end
    end

    #
    def build(directory)
      puts "Building #{directory} ..."

      directory_push(directory)
      build_smeagol
      build_tree(@wiki.repo.tree)
      build_rss
      directory_pop
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
    def fileutils
      FileUtils::Verbose
    end

    #
    def index_directory_hrefs(html)
      html.gsub(/href=\"(.*)\"/) do |match|
        if File.directory?(File.join(current_directory, $1))
          "href=\"#{$1}/index.html\""
        else
          match  # no change
        end
      end
    end

    def build_rss
      rss_file = File.join(current_directory, 'rss.xml')

      puts "write #{rss_file}"

      File.open(rss_file, 'w') do |f|
        f.write(@rss.to_s)
      end
    end
  end

end
