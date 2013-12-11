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
    hashify :Name, :Value

    def initialize(name, value)
      self.Name = name
      self.Value = value
    end

    def Name=(n)
      if not n.kind_of?(String) or n.length >= 256
        raise ArgumentError
      end
      @Name=n
    end

    def Value=(n)
      if not n.kind_of?(String) or n.length >= 256
        raise ArgumentError
      end
      @Value=n
    end
  end
end
