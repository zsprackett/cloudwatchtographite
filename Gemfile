source 'http://rubygems.org'

# Required gems
gem 'bundler'
gem 'unf'
gem 'fog', :git => 'https://github.com/fog/fog.git' # need newer fog than release gem 1.18.0
gem 'excon'
gem 'hashifiable'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'rdoc'
  gem 'rspec'
  gem 'cucumber'
  gem 'jeweler'
end

group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'coveralls', require: false
end
