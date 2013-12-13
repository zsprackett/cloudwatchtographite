require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::MetricDefinition do
  before :each do
    @definition = CloudwatchToGraphite::MetricDefinition.create_and_fill({
      'namespace'  => 'foonamespace',
      'metricname' => 'foometricname',
      'period'     => 90,
      'unit'       => 'Bits',
      'statistics' => ['Sum', 'Average'],
      'dimensions' => [
        { 'name' => 'fooname1', 'value' => 'foovalue1' },
        { 'name' => 'fooname2', 'value' => 'foovalue2' },
      ]
    })
  end

  describe "#create_and_fill" do
    it "should be a MetricDefinition" do
      @definition.should be_an_instance_of CloudwatchToGraphite::MetricDefinition
    end
  end

  describe "#new" do
    it "takes no parameters and returns a MetricDefinition" do
      d = CloudwatchToGraphite::MetricDefinition.new
      d.should be_an_instance_of CloudwatchToGraphite::MetricDefinition
    end
  end

  describe "#Namespace" do
    it "returns the correct namespace" do
      @definition.Namespace.should eql 'foonamespace'
    end
  end

  describe "#MetricName" do
    it "returns the correct metricname" do
      @definition.MetricName.should eql 'foometricname'
    end
  end

  describe "#Statistics" do
    it "returns the correct statistics" do
      statistics = @definition.Statistics
      statistics.should be_an Array
      statistics.should include 'Sum'
      statistics.should include 'Average'
      statistics.should have(2).items
    end
  end

  describe "#Period" do
    it "returns the correct period" do
      @definition.Period.should eql 90
    end
  end

  describe "#Dimensions" do
    it "returns the correct dimensions" do
      dimensions = @definition.Dimensions
      dimensions.should be_an Array
      dimensions.should have(2).items
      dimensions.each do |d|
        d.should be_a Hash
        d.should have_key('Name')
        d.should have_key('Value')
      end
    end
  end

  describe "#Unit" do
    it "returns the correct unit" do
      @definition.Unit.should eql 'Bits'
    end
  end
end
