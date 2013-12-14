$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'coveralls'
require 'rspec'
# must come before app requires
Coveralls.wear!

require 'cloudwatchtographite'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
