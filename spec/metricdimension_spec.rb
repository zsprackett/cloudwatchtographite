require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::MetricDimension do
  before :each do
    @dimension = CloudwatchToGraphite::MetricDimension.new 'testname', 'testval'
  end

  describe "#new" do
    it "takes two parameters and returns a MetricDimension" do
      @dimension.should be_an_instance_of CloudwatchToGraphite::MetricDimension
    end
  end

  describe "#Name" do
    it "returns the correct name" do
      @dimension.Name.should eql 'testname'
    end
  end

  describe "#Value" do
    it "returns the correct value" do
      @dimension.Value.should eql 'testval'
    end
  end
end

