require 'gollum'
require 'ostruct'
require 'yaml'

module Smeagol
  class Wiki < Gollum::Wiki

    # TODO: Report issue that Gollum should set these in some other way so that a subclass
    # doesn't have to do it again.
    self.default_ref = 'master'
    self.default_committer_name  = 'Anonymous'
    self.default_committer_email = 'anon@anon.com'
    self.default_ws_subs = ['_','-']

    # Public: Updates the wiki repository.
    # 
    # git  - The path to the git binary.
    #
    # Returns true if successful. Otherwise returns false.
    def update(git)
      # TODO: Change this method to raise errors if something goes wrong instead
      #       of returning a status.
      
      # If the git executable is available, pull from master and check status.
      if !git.nil?
        output = `cd #{path} && #{git} pull origin master 2>/dev/null`
        
        # Write update to log if something happened
        if output.index('Already up-to-date').nil?
          $stderr.puts "==Repository updated at #{Time.new()} : #{path}=="
        end
    
        return $? == 0
      # Otherwise return false.
      else
        return false
      end
    end

    ##############################################################################
    #
    # Settings
    #
    ##############################################################################

    # The Smeagol wiki settings. These can be found in the smeagol.yaml file at
    # the root of the repository.
    #
    # Returns an OpenStruct of settings.
    def settings
      # Cache settings if already read
      if @settings.nil?
        file = "#{path}/settings.yml"
        if File.readable?(file)
          @settings = YAML::load(IO.read(file)).to_ostruct
        else
          @settings = OpenStruct.new
        end
      end
      return @settings
    end
  end
end
