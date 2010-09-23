require 'gollum'
require 'ostruct'
require 'yaml'

module Smeagol
  class Wiki < Gollum::Wiki
    ##############################################################################
    #
    # Settings
    #
    ##############################################################################

    # The Smeagol wiki settings. These can be found in the smeagol.yaml file at
    # the root of the repository.
    #
    # Returns an OpenStruct of settings.
    def settings
      # Cache settings if already read
      if @settings.nil?
        file = "#{path}/settings.yaml"
        if File.readable?(file)
          @settings = YAML::load(IO.read(file)).to_ostruct
        else
          @settings = OpenStruct.new
        end
      end
      return @settings
    end
  end
end
