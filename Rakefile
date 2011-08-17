desc 'build extensions'
task :build do
  require 'fileutils'
  FileUtils.cd 'ext/harp' do
    system 'ruby extconf.rb'
    system 'make'
  end
end

desc 'run tests'
task :test => :build do
  system 'ruby harp_test.rb'
end

task :default => :test
