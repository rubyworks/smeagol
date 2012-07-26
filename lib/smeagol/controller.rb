module Smeagol

  # Shared controller.
  class Controller

    # Initialize new Controller instance.
    #
    # wiki - Gollum::Wiki
    #
    def initialize(wiki)
      @wiki  = wiki
      #@views = Hash.new{ |h,k| h[k]={} }
      #@media = Hash.new{ |h,k| h[k]={} }
      #@preloaded = {}
    end

    # Access to Gollum::Wiki.
    attr :wiki

    # Public: The Smeagol wiki settings. These can be found in the _settings.yml
    # file at the root of the repository.
    # This method caches the settings for all subsequent calls.
    #
    # TODO: Should settings be coming from current file or from repo version?
    #       This can be tricky. Right now they come from current file, but
    #       In future we probably may need to split this into two config files.
    #       One that comes from version and one that is current.
    #
    # Returns a Settings object.
    def settings
      @settings ||= Settings.load(wiki.path)
    end

    #def view(wiki_file, version='master')
    #  @views[version][wiki_file] ||= create_view(wiki_file, version)
    #end

    # Lookup view by wiki file and version.
    def view(wiki_file, version='master')
      case wiki_file
      when Gollum::Page
        if wiki_file.post?
          Views::Post.new(self, wiki_file, version)
        else
          Views::Page.new(self, wiki_file, version)
        end
      when Gollum::File
        if wiki_file.extname == '.mustache'
          Views::Form.new(self, wiki_file, version)
        else
          nil #Views::Raw.new(self, wiki_file, version)
        end
      end
    end

    # Returns a list of filtered wiki files.
    def wiki_files
      filter(wiki.files + wiki.pages)
    end

    # Collect a list of all views.
    def views(version='master')
      list = []
      wiki_files.each do |file|
        view = view(file, version)
        list << view if view
      end
      list
    end

    # Collect a list of all posts.
    def posts(version='master')
      list = []
      wiki_files.each do |file|
        next unless Gollum::Page === file && file.post?
        list << view(file, version)
      end
      list
    end

    # Returns Array of views.
    #def views(version='master')
    #  wiki_files.map{ |wf| view(wf) }.compact
    #end

    # Media are raw files that simply need to be passed long.
    # Unlike assets they are versioned, but they do not need
    # to be rendered via a view. 
    #def media(version='master')
    #  preload(version)
    #  @media[version].values
    #end

    # Collect a list of all files in assets directory.
    # These files are never versioned.
    def assets
      files = collect_files(wiki.path, 'assets')
      filter(files)
    end

=begin
    #
    def preload(version='master')
      @preloaded[version] ||= (
        filtered_files.each do |file|
          if file.extname == '.mustache'
            view(file, version)
          else
            @media[version][file] = file
          end
        end
        filtered_pages.each do |page|
          view(page, version)
        end
        true
      )
    end
=end


    #
    #def filtered_files
    #  @filtered_files ||= filter(wiki.files)
    #end

    #
    #def filtered_pages
    #  @filtered_pages ||= filter(wiki.pages)
    #end

    #
    def collect_files(base, offset)
      list = []
      dir  = ::File.join(base, offset)
      return list unless File.directory?(dir)

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
        unless settings.include.any?{ |x| File.fnmatch?(x, path) }
          # TODO: If we enforce the use of underscore the we would
          #       not need to filter out settings, partials and static locations.
          # exclude settings file
          next if path == Settings::FILE
#          # exlcude assets
#          next if path.index('assets') == 0
          # exclude template directory (TODO: future version may allow this)
          next if path.index(settings.partials) == 0
          # exclude any files starting with `.` or `_`
          next if path.split('/').any? do |x|
            x.start_with?('_') or x.start_with?('.')
          end
          # exclude any files specifically exluded by settings
          next if settings.exclude.any? do |x|
            ::File.fnmatch?(x, path) ||
              x.end_with?('/') && path.index(x) == 0
          end
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

    # Public: Get a list of plugin files.
    #
    # Returns Array of plugin files.
    #def plugins
    #  files.map do |f|
    #    File.fnmatch?('_plugins/*.rb', f.path)
    #  end
    #end

  end

end
