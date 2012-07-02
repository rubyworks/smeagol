module Smeagol

  # Server configuration.
  #
  class Config

    # Directory which contains user configuration.
    CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || '~/.config'

    # Public: Load Smeagol server configuration.
    #
    # Returns Config object.
    def self.load(file=nil)
      config = {}

      if file
        config.update(load_config(file))
      else
        config.update(load_config('/etc/smeagol'))
        config.update(load_config("#{CONFIG_HOME}/smeagol", '~/.smeagol'))
      end

      new(config)
    end

    # Internal: Searches through the given directories looking for
    # `settings.yml` file. Loads and returns the result of
    # the first file found.
    #
    # Returns Hash of settings and empty Hash if none found.
    def self.load_config(*dirs)
      dirs.each do |dir|
        file = File.join(dir, 'config.yml')
        file = File.expand_path(file)
        if File.exist?(file)
          return YAML.load_file(file)
        end
      end
      return {}
    end

    #
    #
    def initialize(settings={})
      @port          = 4567
      @auto_update   = false
      @cache_enabled = true
      @mount_path    = ''
      @repositories  = []
      @git           = nil

      assign(settings)
    end

    # Given a Hash of settings, assign via writer methods.
    #
    # Returns nothing.
    def assign(settings={})
      settings.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #  A T T R I B U T E S

    # Port to use for server. Default is 4567.
    attr_accessor :port

    # Path to git executable. This should only be needed in special
    # circumstances.
    attr_accessor :git

    # While running server, auto-update wiki every day.
    attr_accessor :auto_update

    # Use page cache to speed up page requests.
    attr_accessor :cache
    alias :cache_enabled  :cache
    alias :cache_enabled= :cache=

    # Serve website via a given base path.
    attr_accessor :base_path
    alias :mount_path  :base_path
    alias :mount_path= :base_path=

    # Wiki repository list.
    #
    # Examples
    #
    #   repositories:
    #     - path: ~/wikis/banana-blog
    #     - cname: blog.bananas.org
    #     - secret: abc123
    #
    attr_reader :repositories

    # Set list of repositories.
    #
    def repositories=(repos)
      @repositories = (
        repos.map do |repo|
          case repo
          when Repository then repo
          else Repository.new(repo) 
          end
        end
      )
    end

    # Ability to access config like hash.
    def [](name)
      instance_variable_get("@#{name}")
    end

    # Encapsulates a repository config entry.
    #
    class Repository
      attr_accessor :path
      attr_accessor :cname
      attr_accessor :secret

      def initialize(opts={})
        opts = OpenStruct.new(opts)
        @path   = opts.path
        @cname  = opts.cname
        @secret = opts.secret
      end
    end

  end

end
