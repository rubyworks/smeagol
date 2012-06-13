require 'optparse'
require 'smeagol'
require 'smeagol/static'

module Smeagol
  # Creates a Generate command object and runs it.
  #
  # argv - command line arguments.
  #
  # Returns nothing.
  def self.generate(argv)
    Generator.new(argv).run
  end

  class Generator
    # Creates a Generate command object.
    #
    # argv - command line arguments.
    #
    # Returns a Smeagol::Commands::Generate object.
    def initialize(argv)
      @argv = argv
    end

    #
    def run
      wiki   = Smeagol::Wiki.new(repo)
      static = Smeagol::Static.new(wiki)

      static.build(build_dir)
    end

    #
    def options
      @options ||= parse_options
    end

    #
    def repo
      options[:repo] || Dir.pwd
    end

    #
    def build_dir
      dir = options[:build_dir] || Dir.pwd
      if File.expand_path(dir) == File.expand_path(repo)
        dir = File.join(dir, 'build')
      end
      dir
    end

  private

    #
    def parse_options
      options = {}

      optparse = ::OptionParser.new do |opts|
        opts.banner = "usage: smeagol-static [options] [path]"

        opts.on('-h', '--help', 'Displays this usage screen') do
          puts opts
          exit
        end

        opts.on('-b', '--build [DIRECTORY]') do |dir|
          options[:build_dir] = dir
        end
      end

      begin
        optparse.parse!
      rescue ::OptionParser::InvalidOption
        puts optparse
        exit 1
      end

      options[:repo] = ARGV.first

      @options = options
    end
  end
end
