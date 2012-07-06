module Smeagol

  # Console encapsulates all the public methods
  # smeagol is likely to need, generally it maps
  # to all the CLI commands.
  #
  module Console
    extend self

    #
    # Initialize a Gollum wiki for use with smeagol.
    #
    def init(*args)
      Init.run(*args)
    end

    #
    # Read in the settings mustache template.
    #
    #def settings_template
    #  IO.read(File.join(File.dirname(__FILE__), "templates/smeagol.yml"))
    #end

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

      Serve.run(config)
    end

    #
    # Generate static build.
    #
    def build(options={})
      Build.run(options)
    end

    #
    # Update/clone site repo.
    #
    def update(options={})
      Update.run(options)
    end

    #
    # Preview a generated build directory. This is useful to 
    # ensure the static build when as expected.
    #
    # TODO: Would be happy to use thin if it supported "site" adapter.
    #
    def preview(options={})
      #build_dir = options[:build_dir] || settings.build_dir
      #system "thin start -A file -c #{build_dir}"
      Static::Server.run(options)
    end

    # Sync site directory to build directory. This command
    # shells out to `rsync`.
    #
    # TODO: Would it be a good idea to create a site
    # branch for the build instead of using a build directory.
    #
    def sync(options={})
      Sync.run(options)
    end

    # Get wiki instance.
    # 
    # Returns Smeagol::Wiki object.
    def wiki(dir=Dir.pwd)
      @wiki ||= Smeagol::Wiki.new(dir)
    end

  end

end
