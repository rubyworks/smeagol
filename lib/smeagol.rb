require 'gollum'
require 'rack/file'
require 'sinatra'
require 'mustache'
require 'tmpdir'

require 'smeagol/version'
require 'smeagol/core_ext/ostruct'

# gollum plugins, can be removed when new version of Gollum is out.
require 'smeagol/plugins/wiki'
require 'smeagol/plugins/file'
require 'smeagol/plugins/page'
require 'smeagol/plugins/blob_entry'

require 'smeagol/wiki'
require 'smeagol/app'
require 'smeagol/cache'
require 'smeagol/config'
require 'smeagol/settings'
require 'smeagol/controller'

require 'smeagol/views/base'
require 'smeagol/views/page'
require 'smeagol/views/post'
require 'smeagol/views/template'
require 'smeagol/views/versions'

require 'smeagol/static/generator'
require 'smeagol/static/server'

require 'smeagol/cli'
require 'smeagol/console'
require 'smeagol/console/base'
require 'smeagol/console/init'
require 'smeagol/console/serve'
require 'smeagol/console/build'
require 'smeagol/console/sync'

