require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

require File.dirname(__FILE__) + '/lib/smeagol'

#############################################################################
#
# Standard tasks
#
#############################################################################

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "smeagol #{Smeagol::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :console do
  sh "irb -rubygems -r ./lib/smeagol.rb"
end


#############################################################################
#
# Packaging tasks
#
#############################################################################

task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "gem build smeagol.gemspec"
  sh "git commit --allow-empty -a -m 'Release #{Smeagol::VERSION}'"
  sh "git tag v#{Smeagol::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Smeagol::VERSION}"
end
