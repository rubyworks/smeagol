module Smeagol

  # Repostiory encapsulation. This class serves two needs,
  # as a wiki repo (for Config) and as a site repo (for Settings).
  # Which fields are actually used depends on which of these
  # two use cases is at play. 
  #
  class Repository

    #
    def initialize(opts={})
      opts = OpenStruct.new(opts)
      @path   = opts.path
      @origin = opts.origin
      @ref    = opts.ref || opts.tag || opts.branch || 'master'
      @bare   = opts.bare
      @secret = opts.secret
      @cname  = opts.cname
      @update = opts.update
    end

    #
    attr_accessor :path

    # Site's git repo uri.
    # e.g. `git@github.com:trans/trans.github.com.git`
    attr_accessor :origin

    # For deployment site, if the repo is using detached branch approach,
    # then specify the branch name here. This will typically be used
    # for GitHub projects using `gh-pages`. Default is `master`.
    attr_accessor :ref

    # Alias for #ref.
    alias tag ref
    alias tag= ref=

    # Alias for #ref.
    alias branch ref
    alias branch= ref=

    # Passcode, if needed to interact with repo.
    attr_accessor :secret

    # Is the repository bare?
    attr_accessor :bare

    #
    attr_accessor :cname

    #
    def auto_update?
      @update
    end

    #
    def repo
      @repo ||= Grit::Repo.new(path, :is_bare=>bare)
    end

    #
    # Pull down any changes.
    #
    def pull
      repo.git.pull({}, 'origin', branch)
    end

    #
    # The old name for #pull.
    #
    alias :update :pull

    #
    # Clone repo to path.
    #
    def clone
      # dummy location
      tmp = ::File.join(::Dir.tmpdir, 'smeagol', Time.to_i)
      git = Grit::Git.new(tmp)
      git.clone({:quiet=>false, :verbose=>true, :progress=>true, :branch=>branch}, origin, path)
    end

  end

end
