require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::MetricDefinition do
  before :each do
    @definition = FactoryGirl.build(
      :metricdefinition,
      MetricName: 'foometricname',
      Namespace:  'foonamespace',
      Unit:       'Bits'
    )

    @valid_string = 'a' * 255
    @invalid_string = 'z' * 256
  end

  describe ".create_and_fill" do
    it "should be a MetricDefinition" do
      expect(@definition).to \
        be_an_instance_of(CloudwatchToGraphite::MetricDefinition)
    end
    it "should require valid arguments" do
      expect {
        CloudwatchToGraphite::MetricDefinition.create_and_fill(
          {'namespace' => 'blah'}
        )
      }.to raise_error(CloudwatchToGraphite::ParseError)
    end
  end

  describe ".new" do
    it "takes no parameters and returns a MetricDefinition" do
      d = CloudwatchToGraphite::MetricDefinition.new
      expect(d).to be_an_instance_of(CloudwatchToGraphite::MetricDefinition)
    end
  end

  describe ".Namespace" do
    it "returns the correct namespace" do
      expect(@definition.Namespace).to eql('foonamespace')
    end
  end

  describe ".Namespace=" do
    it "only accepts valid arguments" do
      expect {
        @definition.Namespace = 123
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
      expect {
        @definition.Namespace = @invalid_string
      }.to raise_error(CloudwatchToGraphite::ArgumentLengthError)
      @definition.Namespace = @valid_string
      expect(@definition.Namespace).to eql(@valid_string)
    end
  end

  describe ".MetricName" do
    it "returns the correct metricname" do
      expect(@definition.MetricName).to eql('foometricname')
    end
  end

  describe ".MetricName=" do
    it "only accepts valid arguments" do
      expect {
        @definition.MetricName = 123
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
      expect {
        @definition.MetricName = @invalid_string
      }.to raise_error(CloudwatchToGraphite::ArgumentLengthError)
      @definition.MetricName = @valid_string
      expect(@definition.MetricName).to eql(@valid_string)
    end
  end

  describe ".Statistics" do
    it "returns the correct statistics" do
      statistics = @definition.Statistics
      expect(statistics).to be_an(Array)
      expect(statistics).to include('Sum')
      expect(statistics).to include('Average')
      expect(statistics).to have_exactly(2).items
    end
  end

  describe ".add_statistic" do
    it "only accepts valid arguments" do
      expect {
        @definition.add_statistic('NotValid')
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
    end
  end

  describe ".add_dimension" do
    it "accepts ten dimensions and no more" do
      dimensions = FactoryGirl.build_list(:metricdimension, 10)
      dimensions.each do |d|
        @definition.add_dimension(d)
      end
      expect {
          @definition.add_dimension(FactoryGirl.build(:metricdimension))
      }.to raise_error(CloudwatchToGraphite::TooManyDimensionError)
    end
  end

  describe ".Period" do
    it "returns the correct period" do
      expect(@definition.Period).to eql(90)
    end
  end

  describe ".Period=" do
    it "only accepts valid arguments" do
      expect {
        @definition.Period = 'abc'
      }.to raise_error(CloudwatchToGraphite::ArgumentTypeError)
      @definition.Period = 1
      expect(@definition.Period).to eql(1)
    end
  end

  describe ".Dimensions" do
    it "returns the correct dimensions" do
      dimensions = FactoryGirl.build_list(:metricdimension, 2)
      dimensions.each do |d|
        @definition.add_dimension(d)
      end
      dimensions = @definition.Dimensions
      expect(dimensions).to be_a(Array)
      expect(dimensions).to have_exactly(2).items
      dimensions.each do |d|
        expect(d).to be_a(Hash)
        expect(d).to have_key('Name')
        expect(d).to have_key('Value')
      end
    end
  end

  describe ".Unit" do
    it "returns the correct unit" do
      expect(@definition.Unit).to eql('Bits')
    end
  end
end
