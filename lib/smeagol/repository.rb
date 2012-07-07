module Smeagol

  # Repostiory settings.
  #
  class Repository

    def initialize(opts={})
      opts = OpenStruct.new(opts)
      @path   = opts.path
      @origin = opts.origin
      @ref    = opts.ref || opts.tag || opts.branch || 'master'
      @bare   = opts.bare
      @secret = opts.secret
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

    # Passcode, if needed to interact with repo.
    attr_accessor :secret

    # Is the repository bare?
    attr_accessor :bare

    # Alias for #ref.
    alias tag ref
    alias tag= ref=

    # Alias for #ref.
    alias branch ref
    alias branch= ref=

    def repo
      @repo ||= Grit::Repo.new(path, :is_bare=>bare)
    end

    # Pull down any changes.
    def pull
      repo.git.pull({}, 'origin', branch)
    end

    # Clone repo to path.
    def clone
      tmp = ::File.join(::Dir.tmpdir, 'smeagol', Time.to_i)
      git = Grit::Git.new(tmp)
      git.clone({:quiet=>false, :verbose=>true, :progress=>true, :branch=>branch}, origin, path)
    end

  end

end
