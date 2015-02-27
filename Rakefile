#/usr/bin/env ruby

desc 'clone wiki'
task 'wiki' do
  if File.directory?('wiki')
    puts 'wiki directory already exists'
    sh 'cd wiki; git pull origin master'
  else
    sh 'git clone git@github.com:rubyworks/smeagol.wiki.git wiki'
  end
end

desc 'run unit tests'
task 'test' do
  sh 'bundle exec rubytest -Itest -Ilib test/test*'
end

