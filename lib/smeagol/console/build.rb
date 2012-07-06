module Smeagol

  module Console

    # Build static site.
    #
    class Build < Base

      # Initialize new Build command.
      def initialize(options={})
        super(options)

        @build_dir = options[:build_dir]
        @update    = options[:update]
        @force     = options[:force]
      end

      #
      attr :build_dir

      #
      def update?
        @update
      end

      #
      def force?
        @force
      end

      # Invoke build procedure.
      #
      # Returns nothing.
      def call
        gen = Smeagol::Static::Generator.new(wiki)

        unless wiki.settings.static or force?
          $stderr.puts "Trying to build non-static site."
          abort "Must set static mode or use force option to proceed."
        end

        wiki.update() if update?

        remove_build

        gen.build(build_path)
      end

      # Full path to build directory.
      #
      # Returns String of build path.
      def build_path
        build_dir || settings.build_path
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
