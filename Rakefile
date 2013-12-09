# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/cloudwatchtographite/version.rb'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "cloudwatchtographite"
  gem.homepage = "http://github.com/zsprackett/cloudwatchtographite"
  gem.license = "MIT"
  gem.summary = %Q{Cloudwatch to Graphite}
  gem.description = %Q{Pull statistics from Amazon Cloudwatch into Graphite}
  gem.email = "zac@sprackett.com"
  gem.authors = ["S. Zachariah Sprackett"]
  gem.version = CloudwatchToGraphite::VERSION::STRING
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :spec

require 'rdoc/task'
require './lib/cloudwatchtographite/version.rb'
Rake::RDocTask.new do |rdoc|
  version =  CloudwatchToGraphite::VERSION::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "CloudwatchToGraphite #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
