# DEPRECATED

module Smeagol

  module Console

    # Sync copies build files to site location.
    # By using a two-stage process between build
    # and site, Smeagol can make use of the rsync
    # tool to better update only the site files that
    # have actually changed.
    #
    # IMPORTANT: This tool shells out to `rsync`!
    #
    class Sync < Base

      # Initialize new Sync console command.
      def initialize(options={})
        super(options)

        @site_dir  = options[:site_dir]
        @build_dir = options[:build_dir]
        @build     = options[:build]
        @update    = options[:update]
      end

      # Site directory path.
      attr_accessor :site_dir

      # Build directory path.
      attr_accessor :build_dir

      # Perform synchronization between build and site locations.
      #
      # TODO: Support rsync filter.
      def call
        build = build_path.chomp('/')
        site  = site_path.chomp('/')

        if build?
          Console.build(:build_dir=>build_dir)
        end

        if update?
          Console.update(:site_dir=>site_dir)
        end

        system "rsync -arv --del --exclude .git* #{build}/ #{site}/"
      end

      # Perform update/clone of repo before sync.
      def update?
        @update
      end

      # Perform static build before sync.
      def build?
        @build
      end

      # Default site directory is `.site` in the wiki repo directory,
      # unless a `site_dir` option is given or setting is changed in
      # `settings.yml`.
      #
      # Returns String of site directory path.
      def site_path
        site_dir || settings.site_path
      end

      # Location of build. By defaul this is `.build` in the wiki
      # repo directory.
      #
      # Returns String of build directory path.
      def build_path
        build_dir || settings.build_path
      end

      #
      def site_origin
        settings.site_origin
      end

      #
      def site_branch
        settings.site_branch
      end

    end

  end

end
