module Smeagol

  #!/usr/bin/env ruby
  # == Double-forking Unix daemon
  #
  # Author:: Rufus Post  (mailto:rufuspost@gmail.com)
  #
  # === How does it work?
  #
  # According to Stevens's Advanced Programming in the UNIX Environment
  # chapter 13, this is the procedure to make a well-behaved Unix daemon:
  #
  # Fork and have the parent exit. This makes the shell or boot script
  # think the command is done. Also, the child process is guaranteed not
  # to be a process group leader (a prerequisite for setsid next)
  # Call setsid to create a new session. This does three things:
  # * The process becomes a session leader of a new session
  # * The process becomes the process group leader of a new process group
  # * The process has no controlling terminal
  # 
  # Optionally fork again and have the parent exit. This guarantes that
  # the daemon is not a session leader nor can it acquire a controlling
  # terminal (under SVR4)
  #
  #  grandparent - the current process
  #   \_ parent  - exits immediately
  #       \_ simple daemon - writes out its pid to file
  #
  # Change the current working directory to / to avoid interfering with
  # mounting and unmounting. By default don't bother to chdir("/") here 
  # because we might to run inside APP_ROOT.
  #
  # Set file mode creation mask to 000 to allow creation of files with any
  # required permission later. By default umask is whatever was set by the 
  # parent process at startup and can be set in config.ru and config_file, 
  # so making it 0000 and potentially exposing sensitive log data can be 
  # bad policy.
  #
  # Close unneeded file descriptors inherited from the parent (there is no
  # controlling terminal anyway): stdout, stderr, and stdin.
  #
  # Nowadays there is a file to track the PID which is used heavily by
  # Linux distribution boot scripts. Be sure to write out the PID of the
  # grandchild, either the return value of the second fork (step 3) or the
  # value of getpid() after step 3.
  #
  class Daemon

    PIDFILE = File.join(Dir.tmpdir, 'smeagol.pid')

    #
    def initialize(options={})
      @pidfile = options[:pidfile] || PIDFILE
      @out     = options[:out]     || File.expand_path('~/smeagol.log') #'/dev/null'
      @err     = options[:err]     || File.expand_path('~/smeagol.log') #'/dev/null'
      @safe    = options[:safe]

      @safe = true if @safe.nil?

      if block_given?
        daemonize!
        loop{ yield }
      end
    end

    #
    attr :pidfile

    #
    attr :out

    #
    attr :err

    #
    attr :safe

    # In the directory where you want your daemon add a git submodule to
    # your project and create a daemon launcher script: 
    #
    #     #!/usr/bin/env ruby
    #
    #     require 'simple_daemon'
    #
    #     $0 = "my daemon"
    #
    #     SimpleDaemon.daemonize! ARGV[0], ARGV[1], ARGV[2]
    #
    #     loop do
    #       sleep 5
    #       puts "tick"
    #       sleep 5
    #       puts "tock"
    #     end
    #
    # make your script executable and run:
    #
    #     $ chmod +x launcher
    #     $ launcher tmp/daemon.pid log/daemon.stdout.log log/daemon.stderr.log
    #
    # check that it is running by with the following:
    #
    #     $ ps aux | grep "my daemon"
    #
    def daemonize! 
      raise 'First fork failed' if (pid = fork) == -1
      exit unless pid.nil?
      Process.setsid
      raise 'Second fork failed' if (pid = fork) == -1
      exit unless pid.nil?
      kill
      write Process.pid
      unless safe
        Dir.chdir '/'
        File.umask 0000
      end
      redirect
    end

    # Attempts to write the pid of the forked process to the pid file.
    # Kills process if write unsuccesfull.
    def write pid
      File.open pidfile, "w" do |f|
        f.write pid
        f.close
      end
      $stdout.puts "Daemon running with pid: #{pid}"
    rescue ::Exception => e
      raise "While writing the PID to file, unexpected #{e.class}: #{e}"
    end

    # Redirect file descriptors inherited from the parent.
    def redirect
      $stdin.reopen '/dev/null'
      $stdout.reopen File.new(out, "a")
      $stderr.reopen File.new(err, "a")
      $stdout.sync = $stderr.sync = true
    end

    #
    def kill
      self.class.kill(pidfile)
    end

    # Read the existing pid from the pid file and signal HUP to process.
    def self.kill(pidfile=PIDFILE)
      opid = open(pidfile).read.strip.to_i
      Process.kill "HUP", opid
      Process.kill "TERM", opid
      $stdout.puts "Process ##{opid} stopped."
    rescue TypeError
      $stdout.puts "#{pidfile} was empty: TypeError"
    rescue Errno::ENOENT
      $stdout.puts "#{pidfile} did not exist: Errno::ENOENT"
    rescue Errno::ESRCH
      $stdout.puts "The process #{opid} did not exist: Errno::ESRCH"
    rescue Errno::EPERM
      raise "Lack of privileges to manage the process #{opid}: Errno::EPERM"
    rescue ::Exception => e
      raise "While signaling the PID, unexpected #{e.class}: #{e}"
    end

  end

end
