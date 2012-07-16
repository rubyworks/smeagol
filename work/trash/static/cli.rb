module Smeagol

  module CLI

    # Convert to static site.
    #
    # Update wiki repo and update/clone static site repo, if designated
    # by settings.
    #
    #
    # Returns nothing.
    def static(argv)
      options[:update] = true
      options[:build]  = true

      parser.banner = "usage: smeagol static [OPTIONS]"

      parser.on('-U' '--no-update', 'skip repo update') do
        options[:update] = false
      end

      parser.on('-B' '--no-build', 'skip static build') do
        options[:build] = false
      end

      parser.on('-d', '--dir DIR', 'alternate static site directory') do |dir|
        dir = nil if %w{false nil ~}.include?(dir)  # TODO: better approach? 
        options[:dir] = dir
      end

      Console.static(*parse(argv))
    end

    # Preview static build.
    #
    #   TODO: Build if not already built.
    #
    def static_preview(argv)
      parser.banner = "Usage: smeagol-static-preview [OPTIONS]"

      #parser.on('-b', '--build', 'perform build before preview') do
      #  build = true
      #end

      lineno = 1
      parser.on("-e", "--eval LINE", "evaluate a LINE of code") { |line|
        eval line, TOPLEVEL_BINDING, "-e", lineno
        lineno += 1
      }

      parser.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") {
        options[:debug] = true
      }

      parser.on("-w", "--warn", "turn warnings on for your script") {
        options[:warn] = true
      }

      parser.on("-I", "--include PATH",
              "specify $LOAD_PATH (may be used more than once)") { |path|
        (options[:include] ||= []).concat(path.split(":"))
      }

      parser.on("-r", "--require LIBRARY",
              "require the library, before executing your script") { |library|
        options[:require] = library
      }

      parser.on("-s", "--server SERVER", "serve using SERVER (thin/puma/webrick/mongrel)") { |s|
        options[:server] = s
      }

      parser.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") { |host|
        options[:Host] = host
      }

      parser.on("-p", "--port PORT", "use PORT (default: 9292)") { |port|
        options[:Port] = port
      }

      parser.on("-O", "--option NAME[=VALUE]", "pass VALUE to the server as option NAME. If no VALUE, sets it to true. Run '#{$0} -s SERVER -h' to get a list of options for SERVER") { |name|
        name, value = name.split('=', 2)
        value = true if value.nil?
        options[name.to_sym] = value
      }

      parser.on("-E", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
        options[:environment] = e
      }

      parser.on("-D", "--daemonize", "run daemonized in the background") { |d|
        options[:daemonize] = d ? true : false
      }

      parser.on("-P", "--pid FILE", "file to store PID (default: rack.pid)") { |f|
        options[:pid] = ::File.expand_path(f)
      }

      #parser.on_tail("-h", "-?", "--help", "Show this message") do
      #  puts parser
      #  #puts handler_parser(options)
      #  exit
      #end

      #parser.parse!(argv)
      #rack_parser = ::Rack::Server::Options.new(options)
      #rack_options = rack_parser.parse!(argv)
      #@options = rack_options.merge(smeagol_options)

      $stderr.puts "Starting static preview..."

      Console.static_preview(*parse(argv))
    end

    ## Preview site. If in static mode this will preview static build,
    ## otherwise it will serve the Gollum pages directory.
    #def preview(argv)
    #  if static?(argv)
    #    preview_static(argv)
    #  elsif dynamic?(argv)
    #    preview_dynamic(argv)
    #  else
    #    settings = Settings.load(ENV['wiki-dir'])  # pull from end of argv ?
    #    if settings.static
    #      preview_static(argv)         
    #    else
    #      preview_dynamic(argv)
    #    end
    #  end
    #end

    ## Internal: Force static mode?
    #def static?(argv)
    #  return true if argv.delete('--static')
    #  return true if argv.delete('--no-live')
    #  return true if ENV['mode'] && ENV['mode'].downcase == 'static'
    #  return false
    #end

    ## Internal: Force dynamic mode?
    #def dynamic?(argv)
    #  return true if argv.delete('--live')
    #  return true if argv.delete('--no-static')
    #  return true if ENV['mode'] && ENV['mode'].downcase == 'live'
    #  return false
    #end

  end

end
