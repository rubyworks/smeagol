require 'gollum'
require 'mustache'
require 'tmpdir'
require 'smeagol/views/base'
require 'smeagol/views/page'
require 'smeagol/views/versions'

module Smeagol
  class App
    ##############################################################################
    #
    # Settings
    #
    ##############################################################################

    set :public, File.dirname(__FILE__) + '/public'
    

    ##############################################################################
    #
    # Routes
    #
    ##############################################################################

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
      wiki = Smeagol::Wiki.new(repository.path)
      Mustache.render(get_template('versions'), Smeagol::Views::Versions.new(wiki))
    end


    # All other resources go through Gollum.
    get '/*' do
      splat = params[:splat].first

      # If the path starts with a version identifier, use it.
      version = 'master'
      tag_name = nil
      if splat.index(/^v\d/)
        repo = Grit::Repo.new(repository.path)
        tag_name = splat.split('/').first
        repo.tags.each do |tag|
          if tag.name == tag_name
            version = tag.commit.id
            splat = splat.split('/')[1..-1].join('/')
          end
        end
      end
      
      name = splat
      name = "Home" if name == ""
      name = name.gsub(/\/+$/, '')
      name = File.sanitize_path(name)
      file_path = "#{repository.path}/#{name}"
      
      # Load the wiki settings
      wiki = Smeagol::Wiki.new(repository.path)
      cache = Smeagol::Cache.new(wiki)
      
      # First check the cache
      if settings.cache_enabled && cache.cache_hit?(name, version)
        cache.get_page(name, version)
      # Then try to create the wiki page
      elsif page = wiki.page(name, version)
        content = Mustache.render(get_template('page'), Smeagol::Views::Page.new(page, tag_name))
        cache.set_page(name, page.version.id, content) if settings.cache_enabled
        content
      # If it is a directory, redirect to the index page
      elsif File.directory?(file_path)
        url = "/#{name}/index.html"
        url = "/#{tag_name}#{url}" unless tag_name.nil?
        redirect url
      # If it is not a wiki page then try to find the file
      elsif file = wiki.file(name, version)
        content_type get_mime_type(name)
        file.raw_data
      # Otherwise return a 404 error
      else
        raise Sinatra::NotFound
      end
    end


    ##############################################################################
    #
    # Private methods
    #
    ##############################################################################
  
    private
    # The Mustache template to use for page rendering.
    #
    # name - The name of the template to use.
    #
    # Returns the content of the page.mustache file in the root of the Gollum
    # repository if it exists. Otherwise, it uses the default page.mustache file
    # packaged with the Smeagol library.
    def get_template(name)
      if File.exists?("#{repository.path}/#{name}.mustache")
        IO.read("#{repository.path}/#{name}.mustache")
      else
        IO.read(File.join(File.dirname(__FILE__), "templates/#{name}.mustache"))
      end
    end

    # Retrieves the mime type for a filename based on its extension.
    #
    # file - The filename.
    #
    # Returns the mime type for a file.
    def get_mime_type(file)
      if !file.nil?
        extension = file.slice(file.rindex('.')..-1) if file.rindex('.')
        return Rack::Mime::MIME_TYPES[extension] || 'text/plain'
      end
      
      return 'text/plain'
    end

    # Determines the repository to use based on the hostname.
    def repository
      # Match on hostname
      settings.repositories.each do |repository|
        next if repository.cname.nil?
        if repository.cname.upcase == request.host.upcase
          return repository
        end
      end
      
      # If no match, use the first repository as the default
      settings.repositories.first
    end
  end
end
