module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #
    # Initialize Gollum wiki for use with Smeagol.
    # This will clone the wiki repo, if it doesn't
    # laready exist and create a `smeagol.yml` settings
    # file ready for edit.
    #
    def init(*args)
      options = args.pop
      wiki_url, wiki_dir = *args

      if wiki_url
        system "git clone #{wiki_url} #{wiki_dir}"
      else
        wiki_dir = Dir.pwd
        wiki_url = wiki(wiki_dir).repo.config['remote.origin.url']

        if Settings.exist?(wiki_dir)
          abort "Wiki is already setup for Smeagol."
        end
      end

      settings = Settings.new(
        :remote_wiki => wiki_url
        :remote_site => wiki_url.sub('.wiki', '')
      )

      file = File.join(wiki_dir, "smeagol.yml")

      File.open(file, 'w') do |f|
        text = Mustache.render(settings_template, settings) 
        f.write(text)
      end
    end

    #
    # Read in the settings mustache template.
    #
    def settings_template
      IO.read(File.join(File.dirname(__FILE__), "templates/smeagol.yml"))
    end

    #
    # Run the web server.
    #
    def server_run(options={})
      catch_signals(options)
      show_repository(options)
      auto_update(options)
      clear_caches(options)

      Smeagol::App.set(:repositories, options[:repositories])
      Smeagol::App.set(:git, options[:git])
      Smeagol::App.set(:cache_enabled, options[:cache_enabled])
      Smeagol::App.set(:mount_path, options[:mount_path])
      Smeagol::App.run!(:port => options[:port])
    end

    #
    # Catch signals.
    #
    def catch_signals(options={})
      Signal.trap('TERM') do
        Process.kill('KILL', 0)
      end
    end

    #
    # Show repositories being served
    #
    def show_repository(options={})
      $stderr.puts "\n  Now serving:"
      options[:repositories].each do |repository|
        $stderr.puts "  #{repository[:path]} (#{repository[:cname]})"
      end
      $stderr.puts "\n"
    end

    #
    # Run the auto update process.
    #
    def auto_update(options={})
      if options[:git] && options[:auto_update]
        Thread.new do
          while true do
            sleep 86400
            options[:repositories].each do |repository|
              wiki = Smeagol::Wiki.new(repository[:path])
              wiki.update(options[:git])
            end
          end
        end
      end
    end

    #
    # Clear the caches.
    #
    def clear_caches(options={})
      options[:repositories].each do |repository|
        Smeagol::Cache.new(Gollum::Wiki.new(repository[:path])).clear()
      end
    end

    #
    # Generate the build directory from the wiki repo.
    #
    def static_build(options={})
      # TODO: to set repo we need to use a Dir.chdir block.
      repo = Dir.pwd  #options[:repo] || Dir.pwd

      build_dir = options[:build_dir] || settings.build_dir

      FileUtils.rm_r build_dir if File.exist?(build_dir)

      wiki   = Smeagol::Wiki.new(repo)
      static = Smeagol::Static.new(wiki)

      static.build(build_dir)
      static.save
    end

    #
    # Preview a generated build directory. This is useful to 
    # ensure the static build when as expected.
    #
    # Currently this uses the `thin` gem, but it has issues with
    # directory links not ending in `/index.html`. So...
    #
    # TODO: Replace thin with own Rack based file server.
    #
    def static_preview(options={})
      #build_dir = options[:build_dir] || settings.build_dir
      #system "thin start -A file -c #{build_dir}"
      StaticServer.run(options)
    end

    # Sync site directory to build directory. This command
    # shells out to `rsync`.
    #
    # TODO: Ultimately is might be a good idea to create a site
    # branch for the build instead of using a build directory.
    #
    def static_sync(options={})
      build_dir = options[:build_dir] || settings.build_dir
      build_dir = dir + '/' unless dir.end_with?('/')

      site_dir = options[:site_dir] || settings.site_dir
      site_dir = dir + '/' unless dir.end_with?('/')

      system "rsync -arv --del --exclude .git* #{build_dir} #{site_dir}"
    end

  private

    #
    #
    #
    def wiki(dir=Dir.pwd)
      @wiki ||= Smeagol::Wiki.new(dir)
    end

    #
    # Local wiki settings.
    #
    def settings
      @settings ||= Settings.load
    end
  end

end
