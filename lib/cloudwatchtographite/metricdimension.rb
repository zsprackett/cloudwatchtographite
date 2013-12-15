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
  # A hashable representation of an AWS CloudWatch metric dimension
  class MetricDimension
    attr_reader :Name, :Value
    extend Hashifiable
    hashify 'Name', 'Value'

    def Name=(n)
      CloudwatchToGraphite::Validator::string_shorter_than(n, 256)
      @Name=n
    end

    def Value=(n)
      CloudwatchToGraphite::Validator::string_shorter_than(n, 256)
      @Value=n
    end

    def self.create(name, value)
      md = MetricDimension.new
      md.Name = name
      md.Value = value
      md
    end

    def self.create_from_hash(dhash)
      if dhash.kind_of?(Hash) and dhash.has_key?('name') \
        and dhash.has_key?('value')
          CloudwatchToGraphite::MetricDimension::create(
            dhash['name'],
            dhash['value']
          )
      else
        raise CloudwatchToGraphite::ArgumentTypeError
      end
    end
  end
end
