require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::MetricDimension do
  before :each do
    @dimension = FactoryGirl.build(
      :metricdimension,
      Name: 'testname',
      Value: 'testval'
    )
    @valid_string = 'a' * 255
    @invalid_string = 'z' * 256
  end

  describe ".new" do
    it "takes two parameters and returns a MetricDimension" do
      expect(@dimension).to \
        be_an_instance_of(CloudwatchToGraphite::MetricDimension)
    end
  end

  describe ".create_from_hash" do
    it "should return a MetricDimension" do
      d = CloudwatchToGraphite::MetricDimension.create_from_hash(
        {'name' => 'a', 'value' => 'b'}
      )
      expect(d).to be_an_instance_of(CloudwatchToGraphite::MetricDimension)
    end
    it "should require valid arguments" do
      expect {
        CloudwatchToGraphite::MetricDimension.create_from_hash(
          {'name' => 'blah'}
        )
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
    end
  end

  describe ".Name" do
    it "returns the correct name" do
      expect(@dimension.Name).to eql('testname')
    end
  end

  describe ".Name=" do
    it "only accepts valid arguments" do
      expect {
        @dimension.Name = 123
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
      expect {
        @dimension.Name = @invalid_string
      }.to raise_error(CloudwatchToGraphite::ArgumentLengthError)
      @dimension.Name = @valid_string
      expect(@dimension.Name).to eql(@valid_string)
    end
  end

  describe ".Name" do
    it "returns the correct value" do
      expect(@dimension.Value).to eql('testval')
    end
  end

  describe ".Value=" do
    it "only accepts valid arguments" do
      expect {
        @dimension.Value = 123
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
      expect {
        @dimension.Value = @invalid_string
      }.to raise_error(CloudwatchToGraphite::ArgumentLengthError)
      @dimension.Value = @valid_string
      expect(@dimension.Value).to eql(@valid_string)
    end
  end
end
