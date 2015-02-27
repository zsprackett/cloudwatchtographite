require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "CloudwatchToGraphite::VERSION" do
  it "STRING must be defined" do
    expect(CloudwatchToGraphite::VERSION::STRING).to_not be_empty
  end
end
