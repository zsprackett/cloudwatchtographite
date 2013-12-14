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
  # static methods to validate arguments
  class Validator
    def self.string(n)
      if not n.kind_of?(String)
        raise CloudwatchToGraphite::ArgumentTypeError
      end
    end

    def self.string_shorter_than(n, length)
      self::string(n)
      if n.length >= length
        raise CloudwatchToGraphite::ArgumentLengthError
      end
    end

    def self.string_longer_than(n, length)
      self::string(n)
      if n.length <= length
        raise CloudwatchToGraphite::ArgumentLengthError
      end
    end
  end
end
