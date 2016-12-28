# frozen_string_literal: true
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudwatchToGraphite::Base do
  before :each do
    @base = CloudwatchToGraphite::Base.new 'foo', 'bar', 'us-east-1'
  end

  describe '.new' do
    it 'takes three parameters and returns a CloudwatchToGraphite::Base' do
      expect(@base).to be_an_instance_of(CloudwatchToGraphite::Base)
    end
  end

  describe '.fetch_and_forward' do
  end

  describe '.carbon_prefix=' do
    it 'allows setting a prefix for carbon' do
      expect { @base.carbon_prefix = 123 }.to \
        raise_error(CloudwatchToGraphite::ArgumentTypeError)
      expect { @base.carbon_prefix = '' }.to \
        raise_error(CloudwatchToGraphite::ArgumentLengthError)
      @base.carbon_prefix = 'the_prefix'
      expect(@base.carbon_prefix).to eql('the_prefix')
    end
  end
end
