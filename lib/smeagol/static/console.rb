module Smeagol

  module Console

    #
    # Generate static build.
    #
    def static_build(options={})
      static_path options[:dir]

      if options[:update]
        update options
      end

      generator = Smeagol::Static::Generator.new(wiki)

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
      Static::Server.run(options)
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

  end

end
