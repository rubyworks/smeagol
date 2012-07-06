module Smeagol

  module Console

    # Build static site.
    #
    class Build < Base

      # Initialize new Build command.
      def initialize(options={})
        @wiki_dir  = options[:wiki_dir]  || Dir.pwd
        @build_dir = options[:build_dir] || settings.build_dir
        @force     = options[:force]
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
        wiki   = Smeagol::Wiki.new(wiki_dir)
        static = Smeagol::Static::Generator.new(wiki)

        if !wiki.settings.static && !@force
          $stderr.puts "Trying to build non-static site."
          abort "Must set static mode or use force option to proceed."
        end

        remove_build_dir

        static.build(build_dir)
      end

      # Build directory.
      #
      # Returns String of build path.
      def build_dir
        if settings.build_dir
          if relative?(settings.build_dir)
            File.join(wiki_dir, settings.build_dir)
          else
            settings.build_dir
          end
        else
          File.join(Dir.tmpdir, 'smeagol', 'build')
        end
      end

      # Remove build directory.
      #
      def remove_build_dir
        if File.exist?(build_dir)
          FileUtils.rm_r(build_dir)
        end
      end

      #
      def relative?(path)
        return false if path.start_with?(::File::SEPARATOR)
        return false if path.start_with?('/')
        return false if path.start_with?('.')
        return true
      end

    end

  end

end
