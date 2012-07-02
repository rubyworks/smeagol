module Smeagol

  # Subclass of Gollum::Wiki.
  #
  # TODO: Techincailly this is probably not needed. Presently it only adds
  #       two methods, both of which can easily be placed elsewhere.
  #
  class Wiki < Gollum::Wiki

    # TODO: Wish Gollum let us set these in some other way so that a subclass
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
          $stderr.puts "== Repository updated at #{Time.new()} : #{path} =="
        end
    
        return $? == 0
      # Otherwise return false.
      else
        return false
      end
    end

    # Public: The Smeagol wiki settings. These can be found in the _smeagol/settings.yml
    # file at the root of the repository.
    # This method caches the settings for all subsequent calls.
    #
    # TODO: Should settings be coming from current file or from repo version?
    #       This can be tricky. Right now they come from current file, but
    #       In future we probably need to split this into two config files.
    #       One that comes from version and one that is current.
    #
    # TODO: This might be better in Controller instead.
    #
    # Returns a Settings object.
    def settings
      @settings ||= Settings.load(path)
    end

    # Public: Get a list of plugin files.
    #
    # Returns Array of plugin files.
    #def plugins
    #  files.map do |f|
    #    File.fnmatch?('_smeagol/plugins/*.rb', f.path)
    #  end
    #end

  end

end
