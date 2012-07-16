module Smeagol

  # Wiki settings.
  #
  # TODO: Would it be possible/prudent to move all this into controller?
  class Settings

    # The name of the settings file.
    # TODO: Rename to `_smeagol.yml` ?
    FILE = "_settings.yml"

    # Default template includes directory.
    PARTIALS = '_partials'

    # Default build-to directory for static builds.
    SITE_DIR = '_public'

    # Default sync command.
    SYNC_SCRIPT = "rsync -arv --del --exclude .git* '%s/' '%s/'"

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
      @sync_script   = SYNC_SCRIPT
      @site_path     = SITE_DIR
      @static        = false

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

    # If a site is for static deployment, `static` should be set to `true`. 
    attr_accessor :static

    #
    def site
      {'path'=>site_path, 'origin'=>site_origin, 'branch'=>site_branch}
    end

    #
    def site=(entry)
      case entry
      when Hash
        self.site_path   = site['path']
        self.site_origin = site['origin']
        self.site_branch = site['branch']
      else
        self.site_path = site.to_s     
      end
    end

    # Default value is `./_public`, which is relative to
    # the wiki's location. Be sure to add this to the wiki's
    # `.gitignore` file, if it is.
    #
    attr_accessor :site_path

    # If deployment of a site is done via git, you can use `site` to setup
    # a Repository instance that can handle pulls and pushes on updates.
    #
    #   site:
    #     origin: git@github.com:trans/trans.github.com.git
    #     branch: gh-pages
    #
    attr_accessor :site_origin

    # Special branch if using silly branch style, e.g. `gh-pages`.
    attr_accessor :site_branch

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

    # TODO: I hate this. Make's me want to swtich to liquid templates.
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

    # Smeagol uses `rsync` to copy build files from temporary location to
    # the final location given by `static`. By default this command is:
    #
    #   "rsync -arv --del --exclude .git* %s/ %s/"
    #
    # Where the first %s is the temporary location and the second is the location
    # specified by the `static` setting. If this needs to be different it can
    # be change here. Just be sure to honor the `%s` slots.
    #
    # If set to `~` (ie. `nil`) then the static files will be built-out directly
    # to the static directory without using rsync.
    attr_accessor :sync_script

    # Expanded site directory.
    #
    # If `site_path` is an absolute path it will returned as given, 
    # otherwise this will be relative to the location of the wiki.
    #
    # Returns String of build path.
    def full_site_path
      path = relative?(site_path) ? ::File.join(wiki_dir, site_path) : site_path
      path.chomp('/')  # ensure no trailing path separator
      path
    end

    #
    # TODO: raise error is no site settings?
    #
    # Returns Repository object for git-based deployment site.
    def site_repo
      @site_repo ||= (
        opts = (site || {}).dup
        opts[:path] = full_site_path
        Repository.new(opts)
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
