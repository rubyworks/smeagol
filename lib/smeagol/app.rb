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
        repository.update
        'ok'
      else
        # Show a forbidden response if the secret was not correct
        'forbidden'
      end
    end

    # Lists the tagged versions of the repo.
    get '/versions' do
      wiki = Smeagol::Wiki.new(repository.path, {:base_path => mount_path})
      ctrl = Smeagol::Controller.new(wiki)
      view = Smeagol::Views::Versions.new(ctrl)
      Mustache.render(view.layout, view)
    end

    # Assets are placed in the `.smeagol/assets` directory and are always
    # served unversioned directly from the file system and not via the
    # git repo.
    get '/assets/*' do
      name = params[:splat].first
      file_path = "#{settings.smeagol_dir}/assets/#{name}"
      if File.exist?(file_path)
        content = File.read(file_path)
        content_type get_mime_type(name)
        content
      else
        # TODO: 404
      end
    end

    # TODO: Instead of using `/^v\d/` as a match of versioned pages,
    #       use `/v/{tag_name}` path instead.

    # All other resources go through Gollum.
    get '/*' do
      wiki  = Smeagol::Wiki.new(repository.path, :base_path => mount_path)
      cache = Smeagol::Cache.new(wiki)
      ctrl  = Smeagol::Controller.new(wiki) # settings)

      name, version, tag_name = parse_params(params)

      name = (ctrl.settings.index || "Home") if name == ""
      name = name.gsub(/\/+$/, '')
      name = sanitize_path(name)
      file_path = "#{repository.path}/#{name}"

      # First check the cache
      if settings.cache_enabled && cache.cache_hit?(name, version)
        cache.get_page(name, version)
      # Then try to create the wiki page
      elsif page = wiki.page(name, version)
        if page.post?
          content = ctrl.render(page, version)
        else
          content = ctrl.render(page, version)
        end
        cache.set_page(name, page.version.id, content) if settings.cache_enabled
        content
      # If it is not a wiki page then try to find the file
      elsif file = wiki.file(name+'.mustache', version)
        content = ctrl.render(file, version)
        cache.set_page(name, file.version.id, content) if settings.cache_enabled
        content
      # Smeagol can create an RSS feed automatically.
      elsif name == 'rss.xml'
        rss = RSS.new(ctrl, :version=>version)
        content = rss.to_s
        content_type 'application/rss+xml' 
        content
      # Smeagol can create a JSON-formatted table of contents.
      elsif name == 'toc.json'
        toc = TOC.new(ctrl, :version=>version)
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

    #
    # If the path starts with a version identifier, use it.
    #
    # params - The request parameters. [Hash]
    #
    # Returns the version number. [String]
    #
    def parse_params(params)
      name     = params[:splat].first
      version  = 'master'
      tag_name = nil

      if name.index(/^v\d/)
        repo = Grit::Repo.new(repository.path)
        tag_name = name.split('/').first
        repo_tag = repo.tags.find do |tag|
          tag_name == tag.name or tag_name == "v#{tag.name}"
        end
        if repo_tag
          version = repo_tag.name #repo_tag.commit.id
          name = name.split('/')[1..-1].join('/')
        else
          # TODO: page not found
        end
      end

      return name, version, tag_name
    end

    #
    # Retrieves the mime type for a filename based on its extension.
    #
    # file - The filename. [String]
    #
    # Returns the mime type for a file. [String]
    #
    def get_mime_type(file)
      unless file.nil?
        extension = ::File.extname(file)
        return Rack::Mime::MIME_TYPES[extension] || 'text/plain'
      end
      
      return 'text/plain'
    end

    #
    # Determines the repository to use based on the hostname.
    #
    # Returns the matching repository. [Repository]
    #
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

    #
    # Determines the mounted path to prefix to internal links.
    #
    # Returns the mount path. [String]
    #
    def mount_path
      path = settings.mount_path
      path += '/' unless path.end_with?('/')
      path
    end

    #
    # Removes all references to parent directories (../) in a path.
    #
    # path - The path to sanitize. [String]
    #
    # Returns a clean, pristine path. [String]
    #
    def sanitize_path(path)
      path.gsub(/\.\.(?=$|\/)/, '') unless path.nil?
    end

  end

end
