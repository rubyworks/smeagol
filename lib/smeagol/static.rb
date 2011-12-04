module Smeagol

  class Static
    def initialize(wiki)
      @wiki = wiki
      @directory = []
    end

    def template
      if File.exists?("#{@wiki.path}/page.mustache")
        IO.read("#{@wiki.path}/page.mustache")
      else
        IO.read(File.join(File.dirname(__FILE__), "templates/page.mustache"))
      end
    end

    def current_directory
      @directory.last
    end

    def directory_pop
      @directory.pop()
    end

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
      return if blob.name == 'settings.yml'
      return if File.extname(blob.name) == '.mustache'

      if name = @wiki.page_class.valid_page_name?(blob.name)
        page = @wiki.page(name)

        if name != 'Home'
          directory_push(name)
        end

        puts "write #{current_directory}/index.html"
        File.open("#{current_directory}/index.html", 'w') do |f|
          f.write(Mustache.render(template, Smeagol::Views::Page.new(page)))
        end

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

    def build(directory)
      puts "Building #{directory} ..."

      directory_push(directory)
      build_smeagol
      build_tree(@wiki.repo.tree)
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

  end

end
