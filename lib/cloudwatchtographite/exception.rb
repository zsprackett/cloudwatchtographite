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
  # general exception class.  ancestor to all CloudwatchToGraphite exceptions
  class Exception < ::RuntimeError; end

  # Raised when the arguments are wrong
  class ArgumentError < Exception; end

  # Raised when an argument is too long
  class ArgumentLengthError < ArgumentError; end

  # Raised when an argument is of the wrong type
  class ArgumentTypeError < ArgumentError; end

  # Raised when too many dimensions are specified
  class TooManyDimensionError < Exception; end

  # Raised when parsing fails
  class ParseError < Exception; end

  # Raised when an unknown protocol is used to try to send to graphite
  class ProtocolError < Exception; end
end
