require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CloudwatchToGraphite" do
  it "must be defined" do
    CloudwatchToGraphite::VERSION::STRING.should_not be_empty
  end
end
