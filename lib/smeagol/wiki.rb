module Smeagol

  # Subclass of Gollum::Wiki.
  #
  # TODO: Techincailly this is probably not needed. Presently it only adds
  #       two methods, both of which can be placed elsewhere, albeit #settings
  #       will take some work to move.
  #
  class Wiki < Gollum::Wiki

    # TODO: Wish Gollum let us set these in some other way so that a subclass
    # doesn't have to do it again.
    self.default_ref = 'master'
    self.default_committer_name  = 'Anonymous'
    self.default_committer_email = 'anon@anon.com'
    self.default_ws_subs = ['_','-']

    # TODO: Change update method to raise errors if something goes wrong instead
    #       of returning a status?     

    # Public: Updates the wiki repository.
    #
    # Returns true if successful. Otherwise returns false.
    def update
      output = `cd #{path} && #{git} pull origin master 2>/dev/null`
      return $? == 0
    end

    # Public: The Smeagol wiki settings. These can be found in the _settings.yml
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

  end

end
