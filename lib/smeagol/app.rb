require 'gollum'
require 'sinatra'
require 'mustache'
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
      if Updater.update(settings.git, settings.gollum_path)
        'ok'
      else
        'error'
      end
    end

    # All other resources go through Gollum.
    get '/*' do
      name = params[:splat].first
      name = "Home" if name == ""
      
      # Load the wiki settings
      wiki = Smeagol::Wiki.new(settings.gollum_path)
      if page = wiki.page(name)
        Mustache.render(page_template, Smeagol::Views::Page.new(page))
      elsif file = wiki.file(name)
        content_type file.mime_type
        file.raw_data
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
      if File.exists?("#{settings.gollum_path}/page.mustache")
        IO.read("#{settings.gollum_path}/page.mustache")
      else
        IO.read(File.join(File.dirname(__FILE__), 'templates/page.mustache'))
      end
    end
  end
end
