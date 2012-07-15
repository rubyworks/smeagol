module Smeagol

  # Static requires a couple of additional settings. 
  #
  class Settings

    # Default build-to directory for static builds.
    STATIC_DIR = 'public'

    #
    SYNC_SCRIPT = "rsync -arv --del --exclude .git* '%s/' '%s/'"

    # If a site is for static deployment, `static` should be set to the 
    # build path. The typical value is `./public`, which is relative to
    # the wiki's location. Be sure to add this to the wiki's `.gitignore`
    # file.
    #
    attr_accessor :static

    def static
      @static || STATIC_DIR
    end

    def static=(path)
      if path
        @exclude << path.chomp('/') + '/'
      end
      @static = path
    end

    # Smeagol uses `rsync` to copy build files from temporary location to
    # the final location given by `static`. By default this command is:
    #
    #   "rsync -arv --del --exclude .git* %s/ %s/"
    #
    # Where the first %s is the temporary location and the second is the location
    # specified by the `static` setting. If this needs to be different it can
    # be change here. Just be sure to honor the `%s` slots.
    #
    # If set to `~` (ie. `nil`) then the static files will be built-out directly
    # the the static directory without using rsync.
    attr_accessor :sync_script

    def sync_script
      @sync_script || SYNC_SCRIPT
    end

  end

end
