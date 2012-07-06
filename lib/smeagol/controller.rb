module Smeagol

  # Shared controller.
  class Controller

    # Initialize new Controller instance.
    #
    # wiki - Gollum::Wiki
    #
    def initialize(wiki)
      @wiki  = wiki
      @views = Hash.new{ |h,k| h[k]={} }

      @preloaded_views = {}
    end

    # Access to Gollum::Wiki.
    attr :wiki

    # Smeagol settings for wiki.
    def settings
      wiki.settings
    end

    # Lookup view by wiki file and version.
    def view(wiki_file, version='master')
      @views[version][wiki_file] ||= (
        case wiki_file
        when Gollum::Page
          if wiki_file.post?
            Views::Post.new(wiki_file, version)
          else
            Views::Page.new(wiki_file, version)
          end
        when Gollum::File
          if wiki_file.extname == '.mustache'
            Views::Form.new(wiki_file, version)
          else
            Views::File.new(wiki_file, version)
          end
        end
      )
    end

    #
    def views(version='master')
      preload_views(version)
      @views[version].values
    end

    #
    def preload_views(version='master')
      @preloaded_views[version] ||= (
        filtered_files.each do |file|
          view(file, version)
        end
        filtered_pages.each do |page|
          view(page, version)
        end
        true
      )
    end

    #
    def filtered_files
      @filtered_files ||= filter(wiki.files)
    end

    #
    def filtered_pages
      @filtered_pages ||= filter(wiki.pages)
    end

    # List of files in assets directory. These files
    # are never versioned.
    def assets
      @assets ||= (
        files = collect_files(wiki.path, 'assets')
        filter(files)
      )
    end

    #
    #def collect_files(base, offset)
    #  files = Dir[::File.join(base, offset, '**', '*')]
    #  files.map{ |file| file.sub(/#{Regexp.escape(base)}[\/\#{::File::SEPARATOR}]/, '') }
    #end

    #
    def collect_files(base, offset)
      list = []
      dir  = ::File.join(base, offset)
      ::Dir.entries(dir).each do |path|
        next if path == '.' or path == '..'
        subdir = ::File.join(dir, path)
        if ::File.directory?(subdir)
          sublist = collect_files(base, File.join(offset, path))
          list.concat(sublist)
        else
          list << ::File.join(offset, path)
        end
      end
      list
    end

=begin
    # Collect list of pages.
    def pages
      @pages ||= filtered_pages.select{ |p| !p.post? }
    end

    # Collect list of posts.
    def posts
      @posts ||= filtered_pages.select{ |p| p.post? }
    end

    # Collect list of non-page files to be rendered.
    def files
      @files ||= filtered_files.select{ |f| f.extname == '.mustache' }
    end

    # Collect list of raw asset files.
    def assets
      @assets ||= filtered_files.select{ |f| f.extname != '.mustache' } 
    end

    #
    def page_views(version='master')
      @page_views ||= pages.map{ |page| Views::Page.new(page, version) }
    end

    #
    def post_views(version='master')
      @post_views ||= posts.map{ |post| Views::Post.new(post, version) }
    end

    #
    def file_views(version='master')
      @file_views ||= files.map{ |post| Views::Template.new(file, versionb) }
    end
=end

    # Filter files according to settings `include` and `exclude` fields.
    # Selection block can be given to further filter the list.
    #
    # files - Array of wiki files to be filtered.
    #
    # Returns [Array<String>].
    def filter(files, &selection)
      result = []
      files.map do |file|
        path = (String === file ? file : file.path)
        unless wiki.settings.include.any?{ |x| File.fnmatch?(x, path) }
          # exclude settings file
          next if path == Settings::FILE
          # exclude template directory (TODO: future version may allow this)
          next if path.index(wiki.settings.template_dir) == 0
          # exclude any files starting with `.` or `_`
          next if path.split('/').any? do |x|
            x.start_with?('_') or x.start_with?('.')
          end
          # exclude any files specifically exluded by settings
          next if wiki.settings.exclude.any?{ |x| File.fnmatch?(x, path) }
        end
        result << file
      end
      result = result.select(&selection) if selection
      result
    end

    # Render wiki file.
    #
    # wiki_file - Gollum::Page or Gollum::File.
    # version   - Commit id, branch or tag.
    #
    # Returns [String].
    def render(wiki_file, version='master')
      view = view(wiki_file, version)
      render_view(view)
    end

    # Render view.
    #
    # view - Views::Base subclass.
    #
    # Returns [String].
    def render_view(view)
      if view.layout
        content = Mustache.render(view.layout, view)
      else
        content = view.content
      end

      return content
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

=begin
    #wiki_file, version='master'

    # Render wiki page.
    #
    # page    - Gollum::Page instance.
    # version - Commit id, branch or tag.
    #
    # Returns [Array<Smeagol::Views::Page,String>].
    def render_page(page, version='master')
      model(page).render(version)

      #view    = Smeagol::Views::Page.new(page, version) #tag_name)
      #content = Mustache.render(layout_template(page, 'page'), view)
      #return view, content
    end

    # Render wiki blog post.
    #
    # post    - Gollum::Page instance.
    # version - Commit id, branch or tag.
    #
    # Returns [Array<Smeagol::Views::Post,String>].
    def render_post(post, version='master')
      model(post).render(version)

      #view    = Smeagol::Views::Post.new(post, version) #tag_name)
      #content = Mustache.render(layout_template(post, 'post'), view)
      #return view, content
    end

    # Render special file.
    #
    # file    - Gollum::File instance.
    # version - Commit id, branch or tag.
    #
    # Returns [Array<Smeagol::Views::Template,String>].
    def render_file(file, version='master')
      model(file).render(version)

      #view    = Smeagol::Views::Template.new(file, version) #tag_name)
      #content = Mustache.render(file.raw_data, view)
      #layname = file.name.chomp('.mustache')
      #layout  = wiki.settings.layouts[layname]
      #unless wiki.settings.layouts.key?(layname) && !layout
      #  view.content = content
      #  content = Mustache.render(layout_template(file, layout || :page), view)
      #end
      #return view, content
    end
=end

#    # The Mustache template to use for page rendering.
#    #
#    # name - The name of the template to use.
#    #
#    # Returns the content of the page.mustache file in the root of the Gollum
#    # repository if it exists. Otherwise, it uses the default page.mustache file
#    # packaged with the Smeagol library.
#    def get_template(name)
#      if File.exists?("#{wiki.path}/#{layout_dir}/#{name}.mustache")
#        IO.read("#{wiki.path}/#{layout_dir}/#{name}.mustache")
#      else
#        IO.read(::File.join(::File.dirname(__FILE__), "templates/layouts/#{name}.mustache"))
#      end
#    end

  end

end
