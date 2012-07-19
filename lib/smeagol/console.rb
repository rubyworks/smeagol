module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #
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
    # If a wiki git URI is given, the clone the wiki.
    #
    # @todo Use grit instead of shelling out.
    #
    def clone_wiki
      system "git clone #{wiki_url} #{wiki_dir}"
    end

    #
    # If the `_settings.yml` file already exists then it is assumed
    # the location has already been prepared for use with Smeagol.
    #
    def abort_if_already_smeagol
      if ::File.exist?(File.join(wiki_dir, '_settings.yml'))
        abort "Looks like the wiki is already setup for Smeagol."
      end
    end

    #
    # When using #init, this provided the initial settings.
    #
    # @returns [Settings]
    #
    def initial_settings
      @settings = Settings.new(
        :wiki_origin => wiki_url,
        :site_origin => wiki_url.sub('.wiki', '')
      )
    end

    #
    # Copy layout templates to `_layouts` directory. 
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
    # Save settings.
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

    #
    # Preview current wiki (from working directory).
    #
    def preview(options)
      repository = {}
      repository[:path]   = Dir.pwd
      #repository[:cname] = options[:cname]  if options[:cname]
      repository[:secret] = options.delete(:secret) if options.key?(:secret)

      options[:repositories] = [repository]

      config = Smeagol::Config.new(options)

      catch_signals
      show_repository(config)

      run_server(config)
    end

    #
    # Serve up sites defined in smeagol config file.
    #
    def serve(options)
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

      #@server_config = config

      catch_signals

      show_repository(config)
      auto_update(config)
      clear_caches(config)

      run_server(config)
    end

    #
    # Setup trap signals.
    #
    def catch_signals
      Signal.trap('TERM') do
        Process.kill('KILL', 0)
      end
    end

    #
    # Returns Smeagol::Config instance.
    #
    attr :server_config

    #
    # Show repositories being served
    #
    def show_repository(server_config)
      $stderr.puts "\n  Now serving on port #{server_config.port} at /#{server_config.base_path}:"
      server_config.repositories.each do |repository|
        $stderr.puts "  * #{repository.path} (#{repository.cname})"
      end
      $stderr.puts "\n"
    end

    #
    # Run the auto update process.
    #
    def auto_update(server_config)
      return unless server_config.auto_update
      Thread.new do
        while true do
          sleep 86400
          server_config.repositories.each do |repository|
            next unless repository.auto_update?
            out = repository.update
            out = out[1] if Array === out
            if out.index('Already up-to-date').nil? 
              $stderr.puts "== Repository updated at #{Time.new()} : #{repository.path} =="
            end
          end
        end
      end
    end

    #
    # Clear the caches.
    #
    def clear_caches(server_config)
      server_config.repositories.each do |repository|
        Smeagol::Cache.new(Gollum::Wiki.new(repository.path)).clear()
      end
    end

    #
    # Run the web server.
    #
    def run_server(server_config)
      #Smeagol::App.set(:git, server_config.git)
      Smeagol::App.set(:repositories, server_config.repositories)
      Smeagol::App.set(:cache_enabled, server_config.cache_enabled)
      Smeagol::App.set(:mount_path, server_config.mount_path)
      Smeagol::App.run!(:port => server_config.port)
    end

    #
    # Update/clone site repo.
    #
    # TODO: update all repos in smeagol/config.yml ?
    #
    def update(options={})
      wiki.repo.git.pull({}, 'orgin', 'master')

      #if settings.site
      #  if Dir.exist?(site_path)
      #    $stderr.puts "Pulling `#{repo.branch}' from `origin' in `#{repo.path}'..."
      #    repo.pull
      #  else
      #    $stderr.puts "Cloning `#{repo.origin}' in `#{repo.path}'..."
      #    repo.clone
      #  end
      #end
    end

    #
    # Static site directory path.
    #
    # @returns [String]
    #
    def site_path
      settings.site_path
    end

    #
    # Site repository.
    #
    # @returns [Repository]
    #
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

    #
    # Current wiki directory.
    #
    # @returns [String]
    #
    def wiki_dir
      @wiki_dir || Dir.pwd
    end

    #
    # Get and cache Wiki object.
    #
    # @returns [Smeagol::Wiki]
    #
    def wiki
      @wiki ||= Smeagol::Wiki.new(wiki_dir)
    end

    #
    # Local wiki settings.
    #
    # @returns [Smeagol::Settings]
    #
    def settings
      @settings ||= Settings.load(wiki_dir)
    end

    #
    # Git executable.
    #
    # @returns [String]
    #
    def git
      Smeagol.git
    end

  end

end
