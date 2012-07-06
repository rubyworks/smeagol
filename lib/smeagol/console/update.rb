module Smeagol

  module Console

    # Update site repo, clone if not present.
    #
    # IMPORTANT: This tool shells out to `git`!
    #
    class Update < Base

      # Initialize new Sync console command.
      def initialize(options={})
        super(options)

        @site_dir = options[:site_dir]
      end

      # Site directory path.
      attr_accessor :site_dir

      # Perform update or clone.
      def call
        site = site_path.chomp('/')

        #wiki.update

        if Dir.exist?(site)
          Dir.chdir(site) do
            system "#{git} pull origin #{site_branch}"
          end
        else
          system "#{git} clone #{site_origin} #{site}"
        end
      end

      # Default site directory is `.site` in the wiki repo directory,
      # unless a `site_dir` option is given or setting is changed in
      # `settings.yml`.
      #
      # Returns String of site directory path.
      def site_path
        site_dir || settings.site_path
      end

      #
      def site_origin
        settings.site_origin
      end

      #
      def site_branch
        settings.site_branch
      end

      #
      def git
        Smeagol.git
      end

    end

  end

end
