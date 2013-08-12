module Smeagol

  # Server configuration is used to store the options for the Smeagol
  # server for serving sites.
  #
  # Configuration can be loaded from configuration files located
  # at `/etc/smaegol/config.yml` and `~/.config/smaegol/config.yml`
  # or `~/.smaegol/config.yml`. Here is an example configuration:
  #
  # Examples
  #
  #   ---
  #   port: 3000
  #   auto_update: true
  #   cache_enabled: true
  #   repositories:
  #     - path: /path/to/wiki/repo
  #       cname: 'domain.name'
  #       origin: 'git@github.com:foo/foo.github.com.wiki.git'
  #       ref: master
  #       bare: false
  #       secret: 'pass123'
  #
  class ServerConfig

    # Directory which contains user configuration.
    CONFIG_HOME = ENV['XDG_CONFIG_HOME'] || '~/.config'

    # Public: Load Smeagol server configuration.
    #
    # Returns [Config]
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
    # dirs - List of directories to search for config file. [Array<String>]
    #
    # Returns configuration settings or empty Hash if none found. [Hash]
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
    # Initialize new Config instance.
    #
    def initialize(settings={})
      @port          = 4567
      @auto_update   = false
      @cache_enabled = true
      @base_path     = ''
      @repositories  = []

      assign(settings)
    end

    #
    # Given a Hash of settings, assign via writer methods.
    #
    def assign(settings={})
      settings.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #  A T T R I B U T E S

    # Port to use for server. Default is 4567.
    attr_accessor :port

    # While running server, auto-update wiki every day.
    attr_accessor :auto_update
    alias :update  :auto_update
    alias :update= :auto_update=

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

    #
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

    #
    # Deprecated: Ability to access config like hash.
    #
    def [](name)
      instance_variable_get("@#{name}")
    end

    # Lookup git executable.
    #def git
    #  ENV['git'] || ENV['GIT'] || 'git'
    #end

    #
    # Set secret for all repositories.
    #
    def secret=(secret)
      return if secret.nil?
      repositories.each do |repo|
        repo.secret = secret
      end
    end

  end

end
