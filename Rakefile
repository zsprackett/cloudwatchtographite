# encoding: utf-8
# frozen_string_literal: true

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/cloudwatchtographite/version.rb'
Jeweler::Tasks.new do |gem|
  gem.name = 'cloudwatchtographite'
  gem.homepage = 'http://github.com/zsprackett/cloudwatchtographite'
  gem.license = 'MIT'
  gem.summary = 'CloudWatch Metrics to Graphite'
  gem.description = 'Pull statistics from Amazon CloudWatch into Graphite'
  gem.email = 'zac@sprackett.com'
  gem.authors = ['S. Zachariah Sprackett']
  gem.version = CloudwatchToGraphite::VERSION::STRING
  gem.executables = ['cloudwatch_to_graphite']
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'cane/rake_task'
Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 10
  cane.add_threshold 'coverage/.last_run.json', :>=, 70
end

task test: [:spec, :quality]
task default: :test

require 'rdoc/task'
require './lib/cloudwatchtographite/version.rb'
Rake::RDocTask.new do |rdoc|
  version = CloudwatchToGraphite::VERSION::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "CloudwatchToGraphite #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
