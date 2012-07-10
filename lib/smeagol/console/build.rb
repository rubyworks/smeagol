module Smeagol

  module Console

    # Build static site.
    #
    class Build < Base

      # Initialize new Build command.
      def initialize(options={})
        super(options)

        @dir    = options[:dir]
        @update = options[:update]
        @force  = options[:force]
      end

      # Alternate static directory.
      attr :dir

      #
      def update?
        @update
      end

      # Invoke build procedure.
      #
      # Returns nothing.
      def call
        gen = Smeagol::Static::Generator.new(wiki)

        unless settings.static or @dir
          $stderr.puts "Trying to build non-static site."
          abort "Must set static path to proceed."
        end

        Console.update(@options) if update?

        remove_build

        gen.build(build_path)

        if settings.sync_script
          cmd = settings.sync_script % [build_path, static_path]
          $stderr.puts cmd
          system cmd
        end
      end

      # Full path to build directory.
      #
      # Returns String to build path.
      def build_path
        if settings.sync_script
          tmpdir
        else
          static_path
        end
      end

      # Full path to static directory.
      #
      # Returns String of static path.
      def static_path
        (@dir || settings.static_path).chomp('/')
      end

      # Remove build directory.
      #
      def remove_build
        if File.exist?(build_path)
          FileUtils.rm_r(build_path)
        end
      end

    end

  end

end
