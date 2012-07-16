module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #  I N I T

    # Initialize Gollum wiki for use with Smeagol.
    # This will clone the wiki repo, if given and it
    # doesn't already exist and create the `_smeagol`
    # directory.
    #
    def init(*args)
      options = args.pop

      abort "Too many arguments." if args.size > 2

      @wiki_url = args.shift
      @wiki_dir = args.shift

      if @wiki_url
        unless @wiki_dir
          @wiki_dir = File.basename(@wiki_url).chomp('.git')
        end
        @clone = true
      else
        @wiki_dir = Dir.pwd
        @wiki_url = wiki.repo.config['remote.origin.url']
        @clone = false
      end

      if @clone
        clone_wiki
      else
        abort_if_already_smeagol
      end

      copy_layouts

      initial_settings

      save_gitignore
      save_settings
    end

    # The wiki git url.
    attr_accessor :wiki_url

    # Local directory to house wiki repo.
    attr_accessor :wiki_dir

    #
    def clone_wiki
      system "git clone #{wiki_url} #{wiki_dir}"
    end

    #
    def abort_if_already_smeagol
      if ::File.exist?(File.join(wiki_dir, '_layouts'))
        abort "Looks like the wiki is already setup for Smeagol."
      end
    end

    #
    def initial_settings
      @settings = Settings.new(
        :wiki_origin => wiki_url,
        :site_origin => wiki_url.sub('.wiki', '')
      )
    end

    #
    def copy_layouts
      dst = ::File.join(wiki_dir, Settings::LAYOUT_DIR)
      Fileutils.mkdir_p(dst)
      Dir[LIBDIR + '/templates/layouts/*'].each do |src|
        FileUtils.cp_r(src, dst)
      end
    end

    #
    def save_gitignore
      file = File.join(wiki_dir, '.gitignore')
      if File.exist?(file)
        File.open(file, 'a') do |f|
          f.write("_public")
        end
      else
        File.open(file, 'w') do |f|
          f.write("_public")
        end
      end
    end

    #
    def save_settings
      file = File.join(wiki_dir, "_settings.yml")
      text = Mustache.render(settings_template, settings) 
      File.open(file, 'w') do |f|
        f.write(text)
      end
    end

    #
    # Read in the settings mustache template.
    #
    def settings_template
      file = LIBDIR + '/templates/settings.yml'
      IO.read(file)
    end

    #  C O M P I L E

    #
    # Compile site. for static sites this means generating the 
    # static files and synching them to the site path.
    #
    def compile(options={})
      if settings.static
        static_build(options)
      else
        # nothing to do (yet)
      end
    end

    #
    # Generate static build.
    #
    def static_build(options={})
      static_path options[:dir]

      if options[:update]
        update options
      end

      generator = Generator.new(wiki)

      remove_static_build

      generator.build(static_build_path)

      if settings.sync_script
        cmd = settings.sync_script % [build_path, static_path]
        $stderr.puts cmd
        system cmd
      end
    end

    #
    # Preview a generated build directory. This is useful to 
    # ensure the static build went as expected.
    #
    # TODO: Would be happy to use thin if it supported fixed "static" adapter.
    #
    def static_preview(options={})
      #build_dir = options[:build_dir] || settings.build_dir
      #system "thin start -A file -c #{build_dir}"
      StaticServer.run(options)
    end

    # Remove static build directory.
    #
    def remove_static_build
      if File.exist?(static_build_path)
        FileUtils.rm_r(static_build_path)
      end
    end

    # Full path to build directory.
    #
    # Returns String to build path.
    def static_build_path
      if settings.sync_script
        tmpdir
      else
        static_path
      end
    end

    # Full path to static site directory.
    #
    # Returns String of static path.
    def static_path(dir=nil)
      @static_path = dir if dir
      (@static_path || settings.static_path).chomp('/')
    end

    #  S E R V E R

    #
    # Run the web server.
    #
    def serve(options={})
      config_file = options[:config_file]
      config = Config.load(config_file)
      config.assign(options)
      abort "No repositories configured." if config.repositories.empty?

      # Set secret on all repositories if passed in by command line option
      # We can only assume they are all the same, in this case.
      #
      # TODO: Maybe only apply if no secret is given in config file?
      if options[:secret]
        config.repositories.each{ |r| r['secret'] = options['secret'] }
      end

      @server_config = (
        if Smeagol::Config === config
          config
        else
          Smeagol::Config.new(config)
        end
      )

      catch_signals
      show_repository
      auto_update
      clear_caches

      Smeagol::App.set(:git, server_config.git)
      Smeagol::App.set(:repositories, server_config.repositories)
      Smeagol::App.set(:cache_enabled, server_config.cache_enabled)
      Smeagol::App.set(:mount_path, server_config.mount_path)
      Smeagol::App.run!(:port => server_config.port)
    end

    # Returns Smeagol::Config instance.
    attr :server_config

    # Setup trap signals.
    #
    # Returns nothing.
    def catch_signals
      Signal.trap('TERM') do
        Process.kill('KILL', 0)
      end
    end

    # Show repositories being served
    #
    # Returns nothing.
    def show_repository
      $stderr.puts "\n  Now serving on port #{server_config.port} at /#{server_config.base_path}:"
      server_config.repositories.each do |repository|
        $stderr.puts "  * #{repository.path} (#{repository.cname})"
      end
      $stderr.puts "\n"
    end

    # Run the auto update process.
    #
    def auto_update
      if server_config.auto_update
        Thread.new do
          while true do
            sleep 86400
            server_config.repositories.each do |repository|
              out = repository.update
              out = out[1] if Array === out
              if out.index('Already up-to-date').nil? 
                $stderr.puts "== Repository updated at #{Time.new()} : #{repository.path} =="
              end
            end
          end
        end
      end
    end

    # Clear the caches.
    #
    # Returns nothing.
    def clear_caches
      server_config.repositories.each do |repository|
        Smeagol::Cache.new(Gollum::Wiki.new(repository.path)).clear()
      end
    end

    #
    #  U P D A T E
    #

    #
    # Update/clone site repo.
    #
    def update(options={})
      wiki.repo.git.pull({}, 'orgin', 'master')

      if settings.site
        if Dir.exist?(site_path)
          $stderr.puts "Pulling `#{repo.branch}' from `origin' in `#{repo.path}'..."
          repo.pull
        else
          $stderr.puts "Cloning `#{repo.origin}' in `#{repo.path}'..."
          repo.clone
        end
      end
    end

    # Returns String of static site directory path.
    def site_path
      settings.site_path
    end

    # Site repository.
    #
    # Returns Repository instance.
    def site_repo
      settings.site_repo 
    end

    # Sync site directory to build directory. This command
    # shells out to `rsync`.
    #
    # TODO: Would it be a good idea to create a site
    # branch for the build instead of using a build directory.
    #
    #def sync(options={})
    #  Sync.run(options)
    #end

    ## Get wiki instance.
    ## 
    ## Returns Smeagol::Wiki object.
    #def wiki(dir=Dir.pwd)
    #  @wiki ||= Smeagol::Wiki.new(dir)
    #end

    #
    #def initialize(options={})
    #  @options  = options  # in case they need to be reused
    #  @wiki_dir = options[:wiki_dir] || Dir.pwd
    #end

    #
    def wiki_dir
      @wiki_dir || Dir.pwd
    end

    # Get and cache Wiki object.
    #
    # Returns Smeagol::Wiki instance.
    def wiki
      @wiki ||= Smeagol::Wiki.new(wiki_dir)
    end

    # Local wiki settings.
    #
    # Returns Smeagol::Settings instance.
    def settings
      @settings ||= Settings.load(wiki_dir)
    end

    # Git executable.
    def git
      Smeagol.git
    end

    # TODO: Maybe add a random number to be safe.
    #
    # Return String path to system temprorary directory.
    def tmpdir(base=nil)
      if base
        ::File.join(Dir.tmpdir, 'smeagol', base)
      else
        ::File.join(Dir.tmpdir, 'smeagol', Time.now.year.to_s)
      end
    end

  end

end
