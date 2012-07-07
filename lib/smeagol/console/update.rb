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
      end

      # Alternate site directory.
      #attr_accessor :site_dir

      # Perform update or clone.
      def call
        wiki.repo.git.pull({}, 'orgin', 'master')

        if settings.site
          if Dir.exist?(site_path)
            $stderr.puts "Pulling `#{repo.branch}' from `origin' in `#{repo.path}'..."
            repo.pull
          else
            $stderr.puts "Cloning `#{repo.origin}' in `#{repo.path}'..."
            repo.clone
          end
        end
      end

      # Returns String of static site directory path.
      def site_path
        settings.site_path
      end

      # Site repository.
      #
      # Returns Repository instance.
      def repo
        settings.site_repo 
      end

    end

  end

end
