module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #
    def report(msg)
      $stderr.puts msg unless $QUIET
    end

    #
    # Initialize Gollum wiki for use with Smeagol.
    # This will clone the wiki repo, if given and it
    # doesn't already exist and create `_settings.yml`,
    # `_layouts/` and `assets/smeagol/`.
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
    # Copy layout templates to `_layouts` directory. 
    #
    def copy_layouts
      dst_dir = File.join(wiki_dir, '_layouts')
      src_dir = LIBDIR + '/templates/layouts'
      copy_dir(src_dir, dst_dir)
    end

    #
    # Copy assets to `assets` directory. 
    #
    def copy_assets
      dst_dir = File.join(wiki_dir, 'assets')
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
    # Create or append `_site` to .gitignore file.
    #
    def save_gitignore
      file = File.join(wiki_dir, '.gitignore')
      if File.exist?(file)
        File.open(file, 'a') do |f|
          f.write("_site")
        end
      else
        File.open(file, 'w') do |f|
          f.write("_site")
        end
      end
    end

    #
    # Save settings.
    #
    def save_settings(options)
      file = File.join(wiki_dir, "_settings.yml")
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

    #
    # Update/clone site repo.
    #
    # TODO: update all repos in smeagol/config.yml ?
    #
    def update(options={})
      if options[:all]
        file   = options[:config_file]
        config = Config.load(file)
        #config.assign(options)  # TODO: assign secret if given
        abort "No repositories configured." if config.repositories.empty?

        config.repositories.each do |repository|
          out = repository.update
          out = out[1] if Array === out
          if out.index('Already up-to-date').nil? 
            $stderr.puts "Updated: #{repository.path}"
          end
        end
      else
        wiki.repo.git.pull({}, 'origin', 'master')
      end
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
      @settings ||= Settings.load(wiki_dir)
    end

    #
    # Git executable.
    #
    # Returns git command path. [String]
    #
    def git
      Smeagol.git
    end

  end

end
