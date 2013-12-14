require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::LoadMetrics do

  describe "#load_content" do
    it "it should not load invalid metrics" do
      content = {'shmetrics' => 'foo'}
      expect {
        CloudwatchToGraphite::LoadMetrics::load_content(content)
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
    end

    it "it should load valid metrics" do
      content = {
        'metrics'    => [ {
          'namespace'  => 'thenamespace',
          'metricname' => 'themetricname',
          'statistics' => 'Average',
          'period'     => 1,
          'dimensions' => [ { 'name' => 'thename', 'value' => 'thevalue' }]
        }]
      }
      metrics = CloudwatchToGraphite::LoadMetrics::load_content(content)
      metrics.should be_an(Array)
    end
  end
end
