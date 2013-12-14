source 'http://rubygems.org'

# Required gems
gem 'bundler'
gem 'unf'
gem 'fog', :git => 'https://github.com/fog/fog.git' # need newer fog than release gem 1.18.0
# this can go away when fog is released
gem 'excon', '>= 0.1.30'
gem 'hashifiable', '>= 0.1.3'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'rdoc'
  gem 'rspec'
  gem 'cucumber'
  gem 'jeweler'
  gem 'cane'
end

group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'coveralls', require: false
end
