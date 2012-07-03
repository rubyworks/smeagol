module Smeagol

  module Console

    # Build static site.
    #
    class Build < Base

      # Initialize new Build command.
      def initialize(options={})
        @wiki_dir = options[:wiki_dir] || Dir.pwd
        @use_tmp  = options[:use_tmp]
      end

      # Directory contaning the wiki git repository.
      attr :wiki_dir

      # Use system temporary directory, instead of directory 
      # local to wiki repo as build destination?
      #
      # Returns True or False.
      def use_tmp?
        @use_tmp
      end

      # Invoke build procedure.
      #
      # Returns nothing.
      def call
        remove_build_dir

        wiki   = Smeagol::Wiki.new(wiki_dir)
        static = Smeagol::Static::Generator.new(wiki)

        static.build(build_dir)
      end

      # Build directory.
      #
      # Returns String of build path.
      def build_dir
        if use_tmp?
          File.join(Dir.tmpdir, 'smeagol', 'build')
        else
          File.join(wiki_dir, '_build')
        end
      end

      # Remove build directory.
      #
      def remove_build_dir
        if File.exist?(build_dir)
          FileUtils.rm_r(build_dir)
        end
      end

    end

  end

end
