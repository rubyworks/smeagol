module Smeagol

  module Models

    class Post < Base

      alias :post, :wiki_file

      #
      def view(version='master')
        @view ||= Views::Post.new(@wiki_file, version)  # rename version to tag_name ?
      end

      # Render post.
      #
      # version - Commit id, branch or tag.
      #
      # Returns [Array<Smeagol::Views::Post,String>].
      def render(version='master')
        super(version)
      end

      # Get post layout template.
      #
      def standard_layout
        local_layout(:post) || local_layout(:page) || default_layout(:post)
      end

    end

  end

end
