require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:linuxspec) do |t|
  t.pattern = 'test/*/*/*/*/linux/*_serverspec.rb'
end

RSpec::Core::RakeTask.new(:windowsspec) do |t|
  t.pattern = 'test/*/*/*/*/windows/*_serverspec.rb'
end

