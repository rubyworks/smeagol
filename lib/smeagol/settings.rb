module Smeagol

  #
  class Settings

    SETTINGS_FILE = "_smeagol/settings.yml"

    #
    def self.exist?(dir=Dir.pwd)
      File.exist?(File.join(dir, SETTINGS_FILE))
    end

    #
    def self.readable?(dir=Dir.pwd)
      File.exist?(dir) && File.readable?(File.join(dir, SETTINGS_FILE))
    end

    #
    def self.load(file=nil)
      file = file || SETTINGS_FILE
      new YAML.load_file(file)
    end

    #
    def initialize(settings={})
      @site_dir  = '_smeagol/site'
      @build_dir = '_smeagol/build'
      @index     = 'Home'
      @rss       = false

      settings.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    # Site URL.
    # e.g. `http://trans.github.com`
    attr_accessor :url

    # Gollum wiki url.
    # e.g. `git@github.com:trans/trans.github.com.wiki.git`
    attr_accessor :remote_wiki

    # Site's git url.
    # e.g. `git@github.com:trans/trans.github.com.git`
    attr_accessor :remote_site

    # Github project site, if applicable.
    # e.g. `http://github.com/trans`
    attr_accessor :source_url

    # Title of site.
    attr_accessor :title

    # Single line description of site.
    attr_accessor :tagline

    # Detailed description of site.
    attr_accessor :description

    # Primary author/maintainer of site.
    attr_accessor :author

    # Where to sync site. (For static builds only.)
    # Default value is `_smeagol/site`.
    attr_accessor :site_dir

    # Where to build static files. (For static builds only.)
    # Default value is `_smeagol/build`.
    attr_accessor :build_dir

    # Page to use as site index.
    attr_accessor :index

    # Boolean flag to produce an rss.xml feed file for blog posts.
    attr_accessor :rss

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

  end

end
