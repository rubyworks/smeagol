module Smeagol

  # Shared controller.
  class Controller

    # Initialize new Controller instance.
    #
    # wiki - Gollum::Wiki
    #
    def initialize(wiki)
      @wiki     = wiki
    end

    #
    attr :wiki

    #
    def render_page(page, version='master')
      view    = Smeagol::Views::Page.new(page, version) #tag_name)
      content = Mustache.render(get_template('page'), view)
      return view, content
    end

    #
    def render_post(post, version='master')
      view    = Smeagol::Views::Post.new(post, version) #tag_name)
      content = Mustache.render(get_template('post'), view)
      return view, content
    end

    #
    def render_file(file, version='master')
      view    = Smeagol::Views::Template.new(file, version) #tag_name)
      content = Mustache.render(file.raw_data, view)
      layout  = wiki.settings.layouts[file.name]
      unless wiki.settings.layouts.key?(file.name) && !layout
        view.content = content
        content = Mustache.render(get_template(layout || :page), view)
      end
      return view, content
    end

    # The Mustache template to use for page rendering.
    #
    # name - The name of the template to use.
    #
    # Returns the content of the page.mustache file in the root of the Gollum
    # repository if it exists. Otherwise, it uses the default page.mustache file
    # packaged with the Smeagol library.
    def get_template(name)
      if File.exists?("#{wiki.path}/_smeagol/layouts/#{name}.mustache")
        IO.read("#{wiki.path}/_smeagol/layouts/#{name}.mustache")
      else
        IO.read(::File.join(::File.dirname(__FILE__), "templates/layouts/#{name}.mustache"))
      end
    end

  end

end
