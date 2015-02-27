require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe CloudwatchToGraphite::LoadMetrics do
  describe "#load_content" do
    it "it should not load invalid metrics" do
      content = { "shmetrics" => "foo" }
      expect {
        CloudwatchToGraphite::LoadMetrics.load_content(content)
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
    end
  end
end
