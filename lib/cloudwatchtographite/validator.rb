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
      raise ArgumentTypeError unless n.kind_of?(String)
    end

    def self.string_shorter_than(n, length)
      string(n)
      raise ArgumentLengthError unless n.length < length
    end

    def self.string_longer_than(n, length)
      string(n)
      raise ArgumentLengthError unless n.length > length
    end

    def self.hash_with_key(h, key)
      raise ArgumentTypeError unless h.kind_of?(Hash) and h.has_key?(key)
    end

    def self.hash_with_keys(h, keys)
      keys.each do |k|
        hash_with_key(h,k)
      end
    end

    def self.hash_with_key_of_type(h, key, type)
      hash_with_key(h, key)
      raise ArgumentTypeError unless h[key].kind_of?(type)
    end
  end
end
