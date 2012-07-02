module Smeagol

  # Sinatra based app for serving the the site directly
  # from the Gollum wiki repo.
  #
  class App < Sinatra::Base

    #  S E T T I N G S

    set :public_folder, File.dirname(__FILE__) + '/public'

    #  R O U T E S

    # Update the gollum repository
    get '/update/?*' do
      key = params[:splat].first
      
      # If a secret key is specified for the repository, only update if the
      # secret is appended to the URL.
      if repository.secret.nil? || key == repository.secret
        wiki = Smeagol::Wiki.new(repository.path)
        if wiki.update(settings.git)
          'ok'
        else
          'error'
        end
      else
        # Show a forbidden response if the secret was not correct
        'forbidden'
      end
    end

    # Lists the tagged versions of the repo.
    get '/versions' do
      wiki = Smeagol::Wiki.new(repository.path, {:base_path => mount_path})
      Mustache.render(get_template('versions'), Smeagol::Views::Versions.new(wiki))
    end

    # All other resources go through Gollum.
    get '/*' do
      name, version = parse_params(params)

      name = "Home" if name == ""   # TODO wiki.settings.index instead of 'Home'
      name = name.gsub(/\/+$/, '')
      name = sanitize_path(name)
      file_path = "#{repository.path}/#{name}"
      
      wiki  = Smeagol::Wiki.new(repository.path, {:base_path => mount_path})
      cache = Smeagol::Cache.new(wiki)

      controller = Controller.new(wiki) # settings)

      # First check the cache
      if settings.cache_enabled && cache.cache_hit?(name, version)
        cache.get_page(name, version)
      # Then try to create the wiki page
      elsif page = wiki.page(name, version)
        if page.post?
          view, content = controller.render_post(page, version)
        else
          view, content = controller.render_page(page, version)
        end
        cache.set_page(name, page.version.id, content) if settings.cache_enabled
        content
      # If it is not a wiki page then try to find the file
      elsif file = wiki.file(name+'.mustache', version)
        view, content = controller.render_file(file, version)
        cache.set_page(name, file.version.id, content) if settings.cache_enabled
        content
      # Smeagol can create an RSS feed automatically.
      elsif name == 'rss.xml'
        rss = RSS.new(wiki, :version=>version)
        content = rss.to_s
        content_type 'application/rss+xml' 
        content
      # Smeagol can create a JSON-formatted table of contents.
      elsif name == 'toc.json'
        toc = TOC.new(wiki, :version=>version)
        content = toc.to_s
        content_type 'application/json'
        content
      # If it is a directory, redirect to the index page.
      # TODO: The server usually handles this automatically
      # so do we really need this? Just in case, I guess?
      elsif File.directory?(file_path)
        url = "/#{name}/index.html"
        url = "/#{tag_name}#{url}" unless tag_name.nil?
        redirect url
      # If not anything else then it must be a raw asset file.
      elsif file = wiki.file(name, version)
        content_type get_mime_type(name)
        file.raw_data
      # Otherwise return a 404 error
      else
        raise Sinatra::NotFound
      end
    end

    #  P R I V A T E  M E T H O D S
  
    private

    # If the path starts with a version identifier, use it.
    #
    # params - Request parameters.
    #
    # Returns version number String.
    def parse_params(params)
      name     = params[:splat].first
      version  = 'master'
      tag_name = nil

      if name.index(/^v\d/)
        repo = Grit::Repo.new(repository.path)
        tag_name = name.split('/').first
        repo.tags.each do |tag|
          if tag.name == tag_name  # TODO: don't assume actual v prefix
            version = tag.commit.id
            name = name.split('/')[1..-1].join('/')
          end
        end
      end

      return name, version
    end

    # The Mustache template to use for page rendering.
    #
    # name - The name of the template to use.
    #
    # Returns the content of the page.mustache file in the root of the Gollum
    # repository if it exists. Otherwise, it uses the default page.mustache file
    # packaged with the Smeagol library.
    def get_template(name)
      if File.exists?("#{repository.path}/_smeagol/layouts/#{name}.mustache")
        IO.read("#{repository.path}/_smeagol/layouts/#{name}.mustache")
      else
        IO.read(::File.join(::File.dirname(__FILE__), "templates/layouts/#{name}.mustache"))
      end
    end

    # Retrieves the mime type for a filename based on its extension.
    #
    # file - The filename.
    #
    # Returns the mime type for a file.
    def get_mime_type(file)
      if !file.nil?
        extension = ::File.extname(file)
        return Rack::Mime::MIME_TYPES[extension] || 'text/plain'
      end
      
      return 'text/plain'
    end

    # Determines the repository to use based on the hostname.
    #
    # Returns [OpenStruct] repository.
    def repository
      # Match on hostname
      settings.repositories.each do |repository|
        next if repository.cname.nil?
        if repository.cname.upcase == request.host.upcase
          return repository
        end
      end

      # If no match, use the first repository as the default.
      settings.repositories.first
    end

    # Determines the mounted path to prefix to internal links.
    #
    # Returns the mount path.
    def mount_path
      path = settings.mount_path
      path += '/' unless path.end_with?('/')
      path
    end

    # Removes all references to parent directories (../) in a path.
    #
    # path - The path to sanitize.
    #
    # Returns a clean, pristine path.
    def sanitize_path(path)
      path.gsub(/\.\.(?=$|\/)/, '') unless path.nil?
    end

  end

end
