# frozen_string_literal: true
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'coveralls'
require 'rspec'
require 'factory_girl'
require 'rspec/collection_matchers'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
# must come before app requires
Coveralls.wear!

require 'cloudwatchtographite'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

FactoryGirl.find_definitions
