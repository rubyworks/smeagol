require 'gollum'
require 'sinatra'
require 'mustache'

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
      if update()
        'ok'
      else
        'error'
      end
    end

    # All other resources go through Gollum.
    get '/*' do
      name = params[:splat].first
      name = "Home" if name == ""
      
      wiki = Gollum::Wiki.new(settings.gollum_path)
      if page = wiki.page(name)
        Mustache.render(page_template,
          :page => page,
          :title => page.title,
          :content => page.formatted_data
        )
      elsif file = wiki.file(name)
        content_type file.mime_type
        file.raw_data
      end
    end


    ##############################################################################
    #
    # Public methods
    #
    ##############################################################################
  
    # Updates the repository that the server is point at.
    #
    # Returns true if successful. Otherwise returns false.
    def update
      # If the git executable is available, pull from master and check status.
      if !settings.git.nil?
        `#{settings.git} pull origin master`
        return $? == 0
      # Otherwise return false.
      else
        return false
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
