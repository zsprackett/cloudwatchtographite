$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rspec"
require "factory_girl"
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

require "cloudwatchtographite"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

FactoryGirl.find_definitions
