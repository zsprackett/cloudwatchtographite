# _*_ coding: utf-8 _*_
# == Synopsis
# CloudwatchToGraphite retrieves metrics from the Amazon CloudWatch APIs
# and passes them on to a graphite server
#
# == Author
# S. Zachariah Sprackett <zac@sprackett.com>
#
# == License
# The MIT License (MIT)
#
# == Copyright
# Copyright (C) 2013 - S. Zachariah Sprackett <zac@sprackett.com>
#
module CloudwatchToGraphite
  class MetricDimension
    attr_reader :Name, :Value
    extend Hashifiable
    hashify 'Name', 'Value'

    def initialize(name, value)
      self.Name = name
      self.Value = value
    end

    def Name=(n)
      CloudwatchToGraphite::Validator::string_length(n, 256)
      @Name=n
    end

    def Value=(n)
      CloudwatchToGraphite::Validator::string_length(n, 256)
      @Value=n
    end

    def self.create_and_fill(dhash)
      if dhash.kind_of?(Hash) and dhash.has_key?('name') and dhash.has_key?('value')
        MetricDimension.new(dhash['name'], dhash['value'])
      else
        raise CloudwatchToGraphite::ArgumentTypeError
      end
    end
  end
end
