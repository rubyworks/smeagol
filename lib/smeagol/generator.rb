module Smeagol

  module Static

    class Generator

      #
      def initialize(wiki)
        @wiki       = wiki
        @controller = Controller.new(wiki)
        @fileutils  = $DEBUG ? FileUtils::Verbose : FileUtils
      end

      # Instance of Gollum::Wiki.
      attr_reader :wiki

      # Instance of Smeagol::Controller.
      attr_reader :controller

      #
      def settings
        controller.settings
      end

      #
      def wiki_files
        controller.wiki_files
      end

      #
      def wiki_assets
        controller.assets
      end

      #
      def build(directory)
        #puts "Building #{directory} ..."
        @dir = directory
        save
      end

      #
      def save
        #fileutils.mkdir(@dir) unless File.exist?(@dir)

        save_smeagol
        save_rss if settings.rss
        save_toc

        wiki_files.each do |file|
          if view = controller.view(file)
            data = controller.render_view(view)
            path = ::File.join(@dir, view.href)
            write(path, data)
          else
            data = file.raw_data
            path = ::File.join(@dir, file.path)
            write(path, data)
          end
        end

        wiki_assets.each do |file|
          data = ::File.read(::File.join(wiki.path, file))
          path = ::File.join(@dir, file)
          write(path, data)
        end
      end

    private

      # Write content to given path.
      def write(path, content)
        mkdir_p(File.dirname(path))
        puts "write: #{path}"  # log instead?
        File.open(path, 'w') do |f|
          f.write(content.to_s)
        end
      end

=begin
      # Collect list of pages.
      #
      def pages
        @pages ||= (
          filter(@wiki.pages){ |p| !p.post? } #.map do |page|
            #Smeagol::Views::Page.new(page)
          #end
        )
      end

      # Collect list of posts.
      #
      def posts
        @posts ||= (
          filter(@wiki.pages){ |p| p.post? } #.map do |page|
          #  Smeagol::Views::Post.new(page)
          #end
        )
      end

      # Collect list of non-page files to be rendered.
      #
      def files
        @files ||= (
          filter(@wiki.files){ |f| f.extname == '.mustache' } #.map do |file|
          #  Smeagol::Views::Template.new(file)
          #end
        )
      end

      # Collect list of raw asset files.
      #
      def assets
        @assets ||= (
          filter(@wiki.files){ |f| f.extname != '.mustache' } 
        )
      end

      # Filter files according to settings `include` and `exclude` fields.
      # Selection block can be given to further filter the list.
      #
      # paths - Array of paths to be filtered.
      #
      # Returns [Array<String>].
      def filter(paths, &selection)
        result = []
        paths.map do |file|
          unless @wiki.settings.include.any?{ |x| File.fnmatch?(x, file.path) }
            next if file.path.split('/').any? do |x|
              x.start_with?('_') or x.start_with?('.')
            end
            next if @wiki.settings.exclude.any?{ |x| File.fnmatch?(x, file.path) }
          end
          result << file
        end
        result = result.select(&selection) if selection
        result
      end
=end

      # Copy smeagol's default public files to static site.
      # These files are put in a separate `smeagol` directory
      # to avoid name clashes with wiki files.
      def save_smeagol
        src = LIBDIR + '/public/assets'
        dst = File.join(@dir) #, 'assets')
        fileutils.mkdir_p(dst) unless File.directory?(dst)
        fileutils.cp_r(src, dst) 
      end

      # Save tab le of contents.
      def save_toc
        toc  = TOC.new(@controller)
        file = File.join(@dir, 'toc.json')
        write(file, toc)
      end

      # Generate RSS feed from post pages and save.
      def save_rss
        rss = RSS.new(@controller)
        file = File.join(@dir, 'rss.xml')
        write(file, rss)
      end

      # Access to FileUtils.
      #
      def fileutils
        @fileutils
      end

      #
      def mkdir_p(dir_name)
        fileutils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end

    end

  end

end
