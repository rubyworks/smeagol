#$:.unshift(File.dirname(__FILE__))

require 'smeagol/version'
require 'smeagol/core_ext'

# gollum plugins, can be removed when new version of Gollum is out.
require 'smeagol/plugins/wiki'
require 'smeagol/plugins/file'
require 'smeagol/plugins/blob_entry'

require 'smeagol/app'
require 'smeagol/cache'
require 'smeagol/wiki'
require 'smeagol/settings'
require 'smeagol/static/generator'
require 'smeagol/static/server'

require 'smeagol/cli'
require 'smeagol/console'
require 'smeagol/console/base'
require 'smeagol/console/init'
require 'smeagol/console/serve'
require 'smeagol/console/build'
require 'smeagol/console/sync'

