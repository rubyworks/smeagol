module Smeagol
  LIBDIR = File.dirname(__FILE__) + '/smeagol'

  # Locates the git binary in common places in the file system.
  #
  # TODO: Can we use shell.rb for this?
  #
  # TODO: This hsould not be necessary. 99% of the time it's just `git`.
  #       For the rest if $GIT environment variable.
  #
  # Returns String path to git executable.
  def self.git
    ENV['git'] || ENV['GIT'] || 'git'
  end

=begin
  def self.git
    ENV['GIT'] ||= (
      git = nil

      ['/usr/bin', '/usr/sbin', '/usr/local/bin', '/opt/local/bin'].each do |path|
        file = "#{path}/git"
        git = file if File.executable?(file)
        break if git
      end
    
      # Alert user that updates are unavailable if git is not found
      if git.nil? || !File.executable?(git)
        warn "warning: git executable could not be found."
      else
        $stderr.puts "git found: #{git}" if $DEBUG
      end

      git
    )
  end
=end

end

require 'gollum'
require 'rack/file'
require 'sinatra'
require 'mustache'
require 'tmpdir'
require 'ostruct'
require 'yaml'
require 'optparse'

require 'smeagol/version'
require 'smeagol/core_ext'

# gollum plugins, can be removed when new version of Gollum is out.
require 'smeagol/gollum/wiki'
require 'smeagol/gollum/file'
require 'smeagol/gollum/page'
require 'smeagol/gollum/blob_entry'

require 'smeagol/wiki'
require 'smeagol/app'
require 'smeagol/cache'
require 'smeagol/config'
require 'smeagol/repository'
require 'smeagol/settings'
require 'smeagol/controller'

require 'smeagol/views/base'
require 'smeagol/views/page'
require 'smeagol/views/post'
require 'smeagol/views/form'
#require 'smeagol/views/file'
require 'smeagol/views/versions'

require 'smeagol/helpers/rss'
require 'smeagol/helpers/toc'

require 'smeagol/generator'
require 'smeagol/static_server'

require 'smeagol/cli'
require 'smeagol/console'
#require 'smeagol/console/base'
#require 'smeagol/console/init'
#require 'smeagol/console/serve'
#require 'smeagol/console/build'
#require 'smeagol/console/update'
#require 'smeagol/console/sync'

