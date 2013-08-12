module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #
    # Print to $stderr unless $QUIET.
    #
    def report(msg)
      $stderr.puts msg unless $QUIET
    end

    #  I N I T

    #
    # Initialize Gollum wiki for use with Smeagol.
    #
    # This will clone the wiki repo if given and it
    # doesn't already exist, and it will create `settings.yml`,
    # `layouts/` and `assets/` in `_smeagol` directory.
    #
    # TODO: Perhaps use a supporting "managed copy" gem in future?
    #
    # TODO: Add --force option to override skips?
    #
    # Returns nothing.
    #
    def init(*args)
      options = (Hash === args.last ? args.pop : {})

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
        if File.exist?(File.join(@wiki_dir, '.git'))
          @wiki_url = wiki.repo.config['remote.origin.url'].to_s
        else
          abort "smeagol: not a git repo."
        end
        @clone = false
      end

      clone_wiki if @clone

      save_settings(options)
      save_gitignore

      copy_layouts unless options[:no_layouts]
      copy_assets  unless options[:no_assets]
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
    # Copy layout templates to `_layouts` directory and 
    # partial templates to `_partials`.
    #
    def copy_layouts
      dst_dir = File.join(wiki_dir, '_smeagol', 'layouts')
      src_dir = LIBDIR + '/templates/layouts'
      copy_dir(src_dir, dst_dir)

      dst_dir = File.join(wiki_dir, '_smeagol', '_partials')
      src_dir = LIBDIR + '/templates/partials'
      copy_dir(src_dir, dst_dir)
    end

    #
    # Copy assets to `assets` directory. 
    #
    def copy_assets
      dst_dir = File.join(wiki_dir, '_smeagol', 'assets')
      src_dir = LIBDIR + '/public/assets'
      copy_dir(src_dir, dst_dir)
    end

    #
    def copy_dir(src_dir, dst_dir)
      FileUtils.mkdir_p(dst_dir)

      Dir[File.join(src_dir, '**/*')].each do |src|
        next if File.directory?(src)
        dst = File.join(dst_dir, src.sub(src_dir, ''))
        copy_file(src, dst)
      end
    end

    #
    def copy_file(src, dst)
      if File.exist?(dst)
        report " skip: #{dst.sub(Dir.pwd,'')}"
      else
        FileUtils.mkdir_p(File.dirname(dst))
        FileUtils.cp(src, dst)
        report " copy: #{dst.sub(Dir.pwd,'')}"
      end
    end

    #
    # Create or append `_smeagol/site` to .gitignore file.
    #
    def save_gitignore
      file = File.join(wiki_dir, '.gitignore')
      if File.exist?(file)
        File.open(file, 'a') do |f|
          f.write("_smeagol/site")
        end
      else
        File.open(file, 'w') do |f|
          f.write("_smeagol/site")
        end
      end
    end

    #
    # Save settings.
    #
    def save_settings(options)
      file = File.join(wiki_dir, '_smeagol', 'settings.yml')
      if File.exist?(file)
        $stderr.puts " skip: #{file}"
      else
        text = Mustache.render(settings_template, initial_settings(options)) 
        File.open(file, 'w') do |f|
          f.write(text)
        end
      end
    end

    #
    # When using #init, this provided the initial settings.
    #
    # @returns [Settings]
    #
    def initial_settings(options={})
      options[:wiki_origin] = wiki_url
      options[:site_origin] = wiki_url.sub('.wiki', '')

      @settings = Settings.new(options)
    end

    #
    # Read in the settings mustache template.
    #
    def settings_template
      file = LIBDIR + '/templates/settings.yml'
      IO.read(file)
    end

    #  P R E V I E W

    #
    # Preview site.
    #
    def preview(options)
      if options[:static]
        static_preview(options)
      else
        dynamic_preview(options)
      end
    end

    #
    # Preview dynamiclly served site (from working directory).
    #
    def dynamic_preview(options)
      repository = {}
      repository[:path]   = Dir.pwd
      #repository[:cname] = options[:cname]  if options[:cname]
      repository[:secret] = options.delete(:secret) if options.key?(:secret)

      options[:repositories] = [repository]

      config = ServerConfig.new(options)

      catch_signals
      show_repository(config)

      run_server(config)
    end

    #
    # Preview a generated static site. This is useful to 
    # ensure the static build went as expected.
    #
    # TODO: Would be happy to use thin if it supported fixed "static" adapter.
    #
    def static_preview(options={})
      #build_dir = options[:build_dir] || settings.build_dir
      #system "thin start -A file -c #{build_dir}"
      StaticServer.run(options)
    end

    #  S E R V E

    #
    # Serve up sites defined in smeagol config file.
    #
    # TODO: How to handle static sites here?
    #
    def serve(options)
      config_file = options[:config_file]
      config = ServerConfig.load(config_file)
      config.assign(options)
      abort "No repositories configured." if config.repositories.empty?

      # Set secret on all repositories if passed in by command line option
      # We can only assume they are all the same, in this case.
      #
      # TODO: Maybe only apply if no secret is given in config file?
      if options[:secret]
        config.repositories.each{ |r| r['secret'] = options['secret'] }
      end

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

    #  U P D A T E

    #
    # Update wiki repo(s).
    #
    def update(*args)
      options  = (Hash === args.last ? args.pop : {})
      wiki_dir = args.first

      if wiki_dir
        dir  = File.expand_path(wiki_dir)
        repo = Repository.new(:path=>dir)
        out  = repo.update
        out  = out[1] if Array === out
        report out
      else
        file   = options[:config_file]
        config = ServerConfig.load(file)
        abort "No repositories configured." if config.repositories.empty?

        config.secret = options[:secret]
        config.repositories.each do |repository|
          report "Updating: #{repository.path}"
          out = repository.update
          out = out[1] if Array === out
          report out
        end
      end
    end

    ##
    ## Update wiki.
    ##
    #def update(options={})
    #  dir  = File.expand_path(wiki_dir)
    #  repo = Smeagol::Repository.new(:path=>dir)
    #  out  = repo.update
    #  out  = out[1] if Array === out
    #  report out
    #end

    #  S P I N

    #
    # Spin static site files and sync them to the site path.
    #
    def spin(options={})
      site_path options[:dir]

      if options[:update]
        update options
      end

      generator = Generator.new(wiki)

      remove_old_build

      generator.build(build_path)

      if settings.site_sync
        cmd = settings.site_sync % [build_path, site_path]
        $stderr.puts cmd
        system cmd
      end
    end


    #  D E P L O Y

    # TODO
    def deploy(options={})
      
    end

    #if settings.site
    #  if Dir.exist?(site_path)
    #    $stderr.puts "Pulling `#{repo.branch}' from `origin' in `#{repo.path}'..."
    #    repo.pull
    #  else
    #    $stderr.puts "Cloning `#{repo.origin}' in `#{repo.path}'..."
    #    repo.clone
    #  end
    #end

    #
    # Site directory path.
    #
    # Returns expanded site path. [String]
    #
    def site_path
      settings.site_path
    end

    # Full path to site directory.
    #
    # Returns String of static path.
    def site_path(dir=nil)
      @site_path = dir if dir
      dir = @site_path || settings.site_path
      dir.chomp('/')
    end

    #
    # Site repository.
    #
    # Returns repository. [Repository]
    #
    def site_repo
      settings.site_repo 
    end

    #
    # Current wiki directory.
    #
    # Returns wiki directory. [String]
    #
    def wiki_dir
      @wiki_dir || Dir.pwd
    end

    #
    # Get and cache Wiki object.
    #
    # Returns wiki. [Wiki]
    #
    def wiki
      @wiki ||= Smeagol::Wiki.new(wiki_dir)
    end

    #
    # Local wiki settings.
    #
    # Returns wiki settings. [Settings]
    #
    def settings
      @settings ||= Smeagol::Settings.load(wiki_dir)
    end

    #
    # Git executable.
    #
    # Returns git command path. [String]
    #
    def git
      Smeagol.git
    end

    # Full path to build directory.
    #
    # Returns String to build path.
    def build_path
      if settings.site_sync
        tmpdir
      else
        site_path
      end
    end

    # Remove static build directory.
    #
    def remove_old_build
      if File.exist?(build_path)
        FileUtils.rm_r(build_path)
      end
    end

    # TODO: Maybe add a random number to be safe.
    #
    # Return String path to system temprorary directory.
    def tmpdir(base=nil)
      if base
        ::File.join(Dir.tmpdir, 'shelob', base)
      else
        ::File.join(Dir.tmpdir, 'shelob', Time.now.year.to_s)
      end
    end

  end

end
