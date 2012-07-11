module Smeagol

  module Console

    # Setup Gollum wiki for use with Smeagol.
    #
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
          @clone = true
        else
          @wiki_dir = Dir.pwd
          @wiki_url = wiki.repo.config['remote.origin.url']
          @clone = false
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
        if @clone
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
        src = LIBDIR + '/templates/layouts'
        dst = ::File.join(wiki_dir, Settings::LAYOUT_DIR)
        FileUtils.cp_r(src, dst)
      end

      #
      def save_gitignore
        file = File.join(wiki_dir, '.gitignore')
        if File.exist?(file)
          File.open(file, 'a') do |f|
            f.write(".build\n.site")
          end
        else
          File.open(file, 'w') do |f|
            f.write(".build\n.site")
          end
        end
      end

      #
      def save_settings
        file = File.join(wiki_dir, "settings.yml")
        text = Mustache.render(settings_template, settings) 
        File.open(file, 'w') do |f|
          f.write(text)
        end
      end

      #
      def settings_template
        file = LIBDIR + '/templates/settings.yml'
        IO.read(file)
      end

    end

  end

end
