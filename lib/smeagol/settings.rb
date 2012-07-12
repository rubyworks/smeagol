module Smeagol

  # Wiki settings.
  #
  # TODO: Would it be possible/prudent to move all this into controller?
  class Settings

    # The name of the settings file.
    # TODO: Rename to `smeagol.yml` ?
    FILE = "_settings.yml"

    # Default template includes directory.
    PARTIALS = '_partials'

    # Load settings.
    #
    # wiki_dir - Local file system location of wiki repo. 
    #
    # Returns [Settings] instance.
    def self.load(wiki_dir=nil)
      wiki_dir = Dir.pwd unless wiki_dir
      file = File.join(wiki_dir, FILE)
      file = File.expand_path(file)
      if File.exist?(file)
        settings = YAML.load_file(file)
      else
        settings = {}
      end

      settings[:wiki_dir] = wiki_dir

      new(settings)
    end

    # Initialize Settings.
    #
    def initialize(settings={})
      @partials  = PARTIALS
      @index         = 'Home'
      @rss           = true
      @exclude       = []
      @include       = []
      @site          = nil
      @date_format   = "%B %d, %Y"

      # TODO: Raise error if no wiki_dir ?
      @wiki_dir = settings[:wiki_dir]

      assign(settings)
    end

    # Deprecated: Access settings like a Hash.
    def [](key)
      __send__(key)
    end

    # Assign settings hash via writer methods.
    #
    # Returns nothing.
    def assign(settings={})
      settings.each do |k,v|
        __send__("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    # Deprecated: Alias for #assign.
    alias update assign

    # Internal: Do not set this settings.yml!
    attr_accessor :wiki_dir

    # Gollum wiki's repo uri.
    # e.g. `git@github.com:trans/trans.github.com.wiki.git`
    attr_accessor :wiki_origin

    # The particular tag or reference id to serve. Default is 'master'.
    attr_accessor :wiki_ref

    # Site's URL. If someone wanted to visit your website, this
    # is the link they would follow, e.g. `http://trans.github.com`
    attr_accessor :url

    # Path Where to sync site. Default value is `_sync`, relative to working wiki
    # directory.
    #attr_reader :sync_dir

    # If deploymet of a site is done via git, you can use `site` to setup
    # a Repository instance that can handle pulls and pushes on updates.
    #
    #   site:
    #     origin: git@github.com:trans/trans.github.com.git
    #     branch: gh-pages
    #
    attr_accessor :site

    # Where to find template partials. This is the location that Mustache uses
    # when looking for partials. The default is `_partials`.
    attr_accessor :partials

    # Page to use as site index. The default is `Home`. A non-wiki
    # page can be used as well, such as `index.html` (well, duh!).
    attr_accessor :index

    # Boolean flag to produce an rss.xml feed file for blog posts.
    attr_accessor :rss

    # Files to include that would not otherwise be included. A good example
    # is `.htaccess` becuase dot files are excluded by default.
    attr_accessor :include

    # Files to exclude that would otherwise be included.
    attr_accessor :exclude

    # Include posts with future dates? By default all posts dated in the
    # future are omitted.
    attr_accessor :future

    # Do not load plugins. (TODO?)
    #attr_accessor :safe

    attr_accessor :date_format


    # Title of site.
    attr_accessor :title

    # Single line description of site.
    attr_accessor :tagline

    # Detailed description of site.
    attr_accessor :description

    # Primary author/maintainer of site.
    attr_accessor :author

    # Menu that can be used in site template.
    #
    # Note this will probably be deprecated as it is easy
    # enough to add a menu to your site's custom page template.
    #
    # Examples
    #
    #   menu:
    #   - title: Blog
    #     href: /
    #   - title: Projects
    #     href: /Projects/
    #   - title: Tools
    #     href: /Tools/
    #   - title: Reads
    #     href: /Reads/
    #
    attr_accessor :menu

    # Google analytics tracking id. Could be used for other such
    # services if custom template is used.
    #
    # Note this will probably be deprecates because you can add
    # the code snippet easily enough to your custom page template.
    attr_accessor :tracking_id

    # Include a GitHub "Fork Me" ribbon in corner of page. Entry 
    # should give color and position separated by a space.
    # The resulting ribbon will have a link to `source_url`.
    #
    # TODO: Rename this `github_forkme` or something like that.
    #
    # Examples
    #
    #   ribbon: red right
    #
    # Note this might be deprecated as one can add it by
    # hand to custom page template.
    attr_accessor :ribbon

    # Project's development site, if applicable.
    # e.g. `http://github.com/trans`
    #
    # TODO: Rename this field.
    attr_accessor :source_url

    # Fully qulaified site build directory.
    #
    # If `static` is an absolute path it will returned as given, 
    # otherwise it will be relative to the location of the wiki.
    #
    # Returns String of build path.
    def static_path
      path = relative?(static) ? ::File.join(wiki_dir, static) : static
      path.chomp('/')  # ensure no trailing path separator
      path
    end

    alias :site_path :static_path

    #
    # TODO: raise error is no site settings?
    #
    # Returns Repository object for git-based deployment site.
    def site_repo
      @site_repo ||= (
        opts = (site || {}).dup
        site[:path] = static_path
        Repository.new(site)
      )
    end

    #  P R I V A T E  M E T H O D S

    private

    #
    def relative?(path)
      return false if path =~ /^[A-Z]\:/
      return false if path.start_with?(::File::SEPARATOR)
      return false if path.start_with?('/')
      #return false if path.start_with?('.')
      return true
    end

  end

end
