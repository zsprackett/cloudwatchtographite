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
  class VERSION
    MAJOR = 0
    MINOR = 0
    PATCH = 0
    BUILD = 'pre1'

    STRING = [MAJOR, MINOR, PATCH].compact.join('.') + (BUILD.empty? ? '' : ".#{BUILD}")
  end
end
