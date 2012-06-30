module Smeagol

  module Console

    # Sync build site to actual site directory.
    # By using a two-stage process between build
    # and site, Smeagol can make use of rsync tool
    # to better update only the site files that
    # have actually changed.
    #
    class Sync < Base

      # Initialize new Sync console command.
      def initialize(options={})
        @wiki_dir  = options[:wiki_dir] || Dir.pwd
        @site_dir  = options[:site_dir] || settings_site_dir || default_site_dir
        @use_tmp   = options[:use_tmp]
        @build     = options[:build]
      end

      # Site directory path.
      attr_accessor :site_dir

      # Use system temporary directory build? If this option was
      # set to perform the build then is needs to also be set to
      # perform the sync.
      def use_tmp?
        @use_tmp
      end

      # Perform synchronization between build and site locations.
      #
      # TODO: Support rsync filter.
      def call
        if build?
          Console.build(:use_tmp=>use_tmp?)
        end

        build_dir = build_dir.chomp('/')
        site_dir  = site_dir.chomp('/')

        system "rsync -arv --del --exclude .git* #{build_dir}/ #{site_dir}/"
      end

      # Build directory.
      #
      # Returns String of build directory path.
      def build_dir
        if use_tmp?
          File.join(Dir.tmpdir, 'smeagol', 'build')
        else
          File.join(wiki_dir, '_smeagol', 'build')
        end
      end

      # Default site directory is `_smeagol/site` unless a
      # `site_dir` entry is given in the `settings.yml` file. 
      # In which case, if the setting is an absolute path,
      # it will be used as give, otherwsie it will be relative
      # to the location of the wiki.
      #
      # Returns String of site directory path.
      def settings_site_dir
        if dir = settings.site_dir
          if dir.start_with?('/')
            dir
          else
            File.join(wiki_dir, dir)
          end
        end
      end

      #
      def default_site_dir
        File.join(wiki_dir, '_smeagol', 'site')
      end

    end

  end

end
