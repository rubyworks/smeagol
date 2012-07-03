module Smeagol
  module Console

    class Init < Base

      def initialize(*args)
        options = args.pop

        abort "Too many arguments." if args.size > 2

        @wiki_url = args.shift
        @wiki_dir = args.shift

        if @wiki_url
          unless @wiki_dir
            @wiki_dir = File.basename(@wiki_url).chomp('.git')
          end
        else
          @wiki_url = wiki(@wiki_dir).repo.config['remote.origin.url']
          @wiki_dir = Dir.pwd
        end
      end

      # The wiki git url.
      attr_accessor :wiki_url

      # Local directory to house wiki repo.
      attr_accessor :wiki_dir

      #
      # Initialize Gollum wiki for use with Smeagol.
      # This will clone the wiki repo, if given and it
      # doesn't already exist and create the `_smeagol`
      # directory.
      #
      def call
        if wiki_url
          clone_wiki
        else
          abort_if_already_smeagol
        end

        copy_layouts

        save_gitignore
        save_settings
      end

    private

      #
      def clone_wiki
        system "git clone #{wiki_url} #{wiki_dir}"
      end

      #
      def abort_if_already_smeagol
        if ::File.exist?(File.join(wiki_dir, '_layouts'))
          abort "Looks like the wiki is already setup for Smeagol."
        end
      end

      #
      def settings
        Settings.new(
          :wiki_origin => wiki_url,
          :site_origin => wiki_url.sub('.wiki', '')
        )
      end

      #
      def copy_layouts
        tmp_dir = File.dirname(__FILE__) + '/templates/layouts'
        FileUtils.cp_r(tmp_dir, wiki_dir, '_layouts')
      end

      #
      def save_gitignore
        file = File.join(wiki_dir, '.gitignore')
        if File.exist?(file)
          File.open(file, 'a') do |f|
            f.write("_build\n_site")
          end
        else
          File.open(file, 'w') do |f|
            f.write("_build\n_site")
          end
        end
      end

      #
      def save_settings
        file = File.join(wiki_dir, "_settings.yml")
        text = Mustache.render(settings_template, settings) 
        File.open(file, 'w') do |f|
          f.write(text)
        end
      end

    end

  end

end
