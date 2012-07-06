module Smeagol

  # Wiki settings.
  #
  # Note not all of these settings are fully supported yet.
  class Settings

    ## Directory which contains user settings.
    ##CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || '~/.config'

    # The name of the settings file.
    # TODO: Rename to `smeagol.yml` ?
    FILE = "settings.yml"

    # Default site directory.
    SITE_DIR  = '.site'

    # Default build directory.
    BUILD_DIR = '.build'

    # Default template includes directory.
    TEMPLATE_DIR = 'assets/includes'

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

    #
    #
    def initialize(settings={})
      @site_dir      = SITE_DIR
      @build_dir     = BUILD_DIR
      @template_dir  = TEMPLATE_DIR
      @index         = 'Home'
      @rss           = false
      @exclude       = []
      @include       = []
      @site_branch   = 'master'

      # TODO: Raise error if no wiki_dir ?
      @wiki_dir = settings[:wiki_dir]

      assign(settings)
    end

    # Deprecated: Access settings like a Hash.
    def [](key)
      __send__(key)
    end

    # Assign settings hash via writer methods.
    def assign(settings={})
      settings.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    # Deprecated: Alias ffor #assign.
    alias update assign

    # Is this a static site, `true` or `false`? This is an important
    # setting! It determines the default actions of certain smeagol
    # commands. For example, if `static` is not set to true, trying to 
    # call `$ smeagol build` will abort with an error message.
    attr_accessor :static

    # Internal: Do not set this settings.yml!
    attr_accessor :wiki_dir

    # Site's URL. If someone wanted to visit your website, this
    # is the link they would follow, e.g. `http://trans.github.com`
    attr_accessor :url


    # Gollum wiki's repo uri.
    # e.g. `git@github.com:trans/trans.github.com.wiki.git`
    attr_accessor :wiki_origin

    # The particular tag or reference id to serve. Default is 'master'.
    attr_accessor :wiki_ref

    # Site's git repo uri.
    # e.g. `git@github.com:trans/trans.github.com.git`
    attr_accessor :site_origin

    # If site is on a special branch, e.g. `gh-pages`.
    # Default branch is `master`.
    attr_accessor :site_branch

    # If your repo is using (stupid) detached branch approach,
    # then specify the branch name here. This will typically
    # be of used for GitHub projects using Pages feature and set
    # to 'gh-pages'.
    attr_accessor :site_branch

    # Where to sync site. (For static builds only.)
    # Default value is `.site`.
    attr_accessor :site_dir

    # Where to build static files. (For static builds only.)
    # Default value is `.build`.
    attr_accessor :build_dir

    # Where to find template includes.
    # Default value is `assets/includes`.
    attr_accessor :template_dir

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

    # Mapping of file to layout to be used to render.
    attr_accessor :layouts


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

    # Fully qulaified build directory.
    #
    # If `build_dir` is an absolute path it will returned as given, 
    # otherwsie it will be relative to the location of the wiki.
    #
    # Returns String of build path.
    def build_path(alt_dir=nil)
      dir = alt_dir || build_dir
      if dir
        relative?(dir) ? ::File.join(wiki_dir, dir) : dir
      else
        ::File.join(Dir.tmpdir, 'smeagol', 'build')
      end
    end

    # Fully qualitfed site directory.
    #
    # If `site_dir` is an absolute path it will returned as given, 
    # otherwsie it will be relative to the location of the wiki.
    #
    # Returns String of site path.
    def site_path(alt_dir=nil)
      dir = alt_dir || site_dir
      if dir
        relative?(dir) ? ::File.join(wiki_dir, dir) : dir
      else
        ::File.join(Dir.tmpdir, 'smeagol', 'site')
      end
    end

    #  P R I V A T E  M E T H O D S

    private

    #
    def relative?(path)
      return false if path.start_with?(::File::SEPARATOR)
      return false if path.start_with?('/')
      return false if path.start_with?('.')
      return true
    end

  end

end
