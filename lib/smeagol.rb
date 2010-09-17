$:.unshift(File.dirname(__FILE__))
require 'smeagol/app'
require 'smeagol/version'

# Require markup libraries, if available
['rdiscount', 'RedCloth'].each do |lib|
  begin
    require lib
  rescue LoadError => e
  end
end
