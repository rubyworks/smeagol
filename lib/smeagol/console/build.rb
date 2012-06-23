module Smeagol

  module Console

    # Build static site.
    #
    class Build < Base

      DIRECTORY = 'build'

      #
      def initialize(options={})
        @wiki_dir  = options[:wiki_dir]  || Dir.pwd
        @build_dir = options[:build_dir] || default_build_dir
        @force     = options[:force]
      end

      # Directory contaning the wiki git repository.
      attr :wiki_dir

      # Directory in which to save static site files.
      attr :build_dir

      #
      def call
        remove_build_dir

        wiki   = Smeagol::Wiki.new(wiki_dir)
        static = Smeagol::Static::Generator.new(wiki)

        static.build(build_dir)
      end

      #
      def default_build_dir
        #File.join(wiki_dir, '_smeagol', settings.build_dir)
        File.join(wiki_dir, '_smeagol', DIRECTORY)
      end

      #
      def remove_build_dir
        if File.exist?(build_dir)
          if build_dir != default_build_dir
            unless force?
              abort "Build directory will be deleted. Use --force to proceed."
            end
          end
          FileUtils.rm_r(build_dir)
        end
      end

    end

  end

end
