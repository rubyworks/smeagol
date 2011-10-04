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
        Dir::mkdir(current_directory)
      end
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

    def build_blob(blob)
      if name = @wiki.page_class.valid_page_name?(blob.name)
        page = @wiki.page(name)

        if name != 'Home'
          directory_push(name)
        end

        File.open("#{current_directory}/index.html", 'w') do |f|
          f.write(Mustache.render(template, Smeagol::Views::Page.new(page)))
        end

        if name != 'Home'
          directory_pop
        end
      else
        file_name = "#{current_directory}/#{blob.name}"
        FileUtils.mkdir_p(File.dirname(file_name))
        File.open(file_name, 'w') do |f|
          f.write(blob.data)
        end
      end
    end

    def build(directory)
      directory_push(directory)
      build_tree(@wiki.repo.tree)
      directory_pop
    end

  end

end
