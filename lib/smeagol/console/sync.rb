module Smeagol

  module Console

    # Sync build site to actual site directory.
    # By using a two-stage process between build
    # and site, Smeagol can make use of rsync tool
    # to better update only the site files that
    # have actually changed.
    #
    class Sync < Base

      #
      def initialize(options={})
        @wiki_dir  = options[:wiki_dir]  || Dir.pwd
        @build_dir = options[:build_dir] || default_build_dir
        @site_dir  = options[:site_dir]  || default_site_dir
      end

      #
      def call
        build_dir = @build_dir.chomp('/')
        site_dir  = @site_dir.chomp('/')

        system "rsync -arv --del --exclude .git* #{build_dir}/ #{site_dir}/"
      end

      #
      def default_build_dir
        #File.join(wiki_dir, '_smeagol', settings.build_dir || 'build')
        File.join(wiki_dir, '_smeagol', 'build')
      end

      #
      def default_site_dir
        File.join(wiki_dir, '_smeagol', settings.site_dir || 'site')
      end

    end

  end

end
