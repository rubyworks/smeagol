require 'gollum'
require 'rack/file'
require 'sinatra'
require 'mustache'
require 'tmpdir'
require 'smeagol/views/page'

module Smeagol
  class App < Sinatra::Base
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
    get '/update' do
      if Updater.update(settings.git, repository_path)
        'ok'
      else
        'error'
      end
    end

    # All other resources go through Gollum.
    get '/*' do
      name = params[:splat].first
      name = "Home" if name == ""
      name = name.gsub(/\/+$/, '')
      name = File.sanitize_path(name)
      file_path = "#{repository_path}/#{name}"
      
      # Load the wiki settings
      wiki = Smeagol::Wiki.new(repository_path)
      cache = Smeagol::Cache.new(wiki)
      
      # First check the cache
      if settings.cache_enabled && cache.cache_hit?(name)
        cache.get_page(name)
      # Then try to create the wiki page
      elsif page = wiki.page(name)
        content = Mustache.render(page_template, Smeagol::Views::Page.new(page))
        cache.set_page(name, content) if settings.cache_enabled
        content
      # If it is a directory, redirect to the index page
      elsif File.directory?(file_path)
        redirect "/#{name}/index.html"
      # If it is not a wiki page then try to find the file
      elsif file = wiki.file(name)
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
    # Returns the content of the page.mustache file in the root of the Gollum
    # repository if it exists. Otherwise, it uses the default page.mustache file
    # packaged with the Smeagol library.
    def page_template
      if File.exists?("#{repository_path}/page.mustache")
        IO.read("#{repository_path}/page.mustache")
      else
        IO.read(File.join(File.dirname(__FILE__), 'templates/page.mustache'))
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

    # Site information such as paths and CNAME information.
    def sites
      if @sites.nil?
        @sites = []
        settings.repository_paths.each do |path|
          wiki = Smeagol::Wiki.new(path)
          @sites.push({:path => path, :cname => wiki.settings.cname})
        end
      end
      
      return @sites
    end

    # Determines the repository to use based on the hostname.
    def repository_path
      # Match on hostname
      sites.each do |site|
        if !site[:cname].nil? && site[:cname].upcase == request.host.upcase
          return site[:path]
        end
      end
      
      # If no match, use the first site as the default
      sites.first[:path]
    end
  end
end
