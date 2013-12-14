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
require 'time'
require 'hashifiable'

module CloudwatchToGraphite
  UNITS = [
    'None',
    'Seconds',
    'Microseconds',
    'Milliseconds',
    'Bytes',
    'Kilobytes',
    'Megabytes',
    'Gigabytes',
    'Terabytes',
    'Bits',
    'Kilobits',
    'Megabits',
    'Gigabits',
    'Terabits',
    'Gigabytes/Second',
    'Terabytes/Second',
    'Bits/Second',
    'Kilobits/Second',
    'Megabits/Second',
    'Gigabits/Second',
    'Terabits/Second',
    'Count/Second'
  ]

  STATISTICS = [
    'Minimum',
    'Maximum',
    'Sum',
    'Average',
    'SampleCount'
  ]

  SETTER_MAPPINGS = {
    'namespace'  => :Namespace=,
    'metricname' => :MetricName=,
    'statistics' => :Statistics=,
    'starttime'  => :StartTime=,
    'endtime'    => :EndTime=,
    'period'     => :Period=,
    'dimensions' => :Dimensions=,
    'unit'       => :Unit=
  }

  class MetricDefinition
    attr_reader :Namespace, :MetricName, :Statistics, :Unit, :Period
    extend Hashifiable
    hashify 'Namespace', 'MetricName', 'Statistics', 'StartTime', 'EndTime', 'Period', 'Dimensions'#, 'Unit'

    def initialize
      @Unit = UNITS[0]
      @Dimensions = []
      @Statistics = []
      @Period = 60
    end

    def Namespace=(n)
      if not n.kind_of?(String)
        raise CloudwatchToGraphite::ArgumentTypeError
      elsif n.length >= 256
        raise CloudwatchToGraphite::ArgumentLengthError
      end
      @Namespace=n
    end

    def MetricName=(n)
      if not n.kind_of?(String)
        raise CloudwatchToGraphite::ArgumentTypeError
      elsif n.length >= 256
        raise CloudwatchToGraphite::ArgumentLengthError
      end
      @MetricName=n
    end

    def StartTime=(time)
      raise CloudwatchToGraphite::ArgumentTypeError unless time.kind_of?(Time)
      @StartTime=time
    end

    def StartTime
      if @StartTime.nil?
        (Time.now-600).iso8601
      else
        @StartTime.iso8601
      end
    end

    def EndTime=(time)
      raise CloudwatchToGraphite::ArgumentTypeError unless time.kind_of?(Time)
      @EndTime=time
    end

    def EndTime
      if @EndTime.nil?
        Time.now.iso8601
      else
        @EndTime.iso8601
      end
    end

    def Period=(n)
      raise CloudwatchToGraphite::ArgumentTypeError unless n.kind_of? Integer
      @Period = n
    end

    def Unit=(n)
      raise CloudwatchToGraphite::ArgumentTypeError unless UNITS.include? n
      @Unit = n
    end

    def Dimensions
      @Dimensions.map(&:to_h)
    end

    def add_statistic(n)
      raise CloudwatchToGraphite::ArgumentTypeError unless STATISTICS.include? n
      if not @Statistics.include? n
        @Statistics.push(n)
      end
    end

    def add_dimension(n)
      if not n.kind_of?(MetricDimension)
        raise CloudwatchToGraphite::ArgumentTypeError
      elsif @Dimensions.length >= 10
        raise CloudwatchToGraphite::TooManyDimensionError
      end
      @Dimensions.push(n)
    end

    def valid?
      if @Namespace.nil? or @MetricName.nil? or @Statistics.empty? or @Dimensions.empty? or @Unit.nil?
        false
      else
        true
      end
    end

    def graphite_path(stat)
     path = "%s.%s.%s.%s" % [self.Namespace, self.MetricName, stat, @Dimensions.join('.')]
     path.gsub('/', '.').downcase
    end

    def self.create_and_fill(definition)
      md = MetricDefinition.new
      definition.each_key do |k|
        case k
        when 'namespace', 'metricname', 'period', 'unit'
          md.send(SETTER_MAPPINGS[k], definition[k])
        when 'starttime', 'endtime'
          begin
            md.send(SETTER_MAPPINGS[k], Time.parse(definition[k]))
          rescue CloudwatchToGraphite::ArgumentTypeError
            raise CloudwatchToGraphite::ParseError
          end
        when 'statistics'
          Array(definition[k]).each do |stat|
            md.add_statistic(stat)
          end
        when 'dimensions'
          Array(definition[k]).each do |dimension|
            md.add_dimension(MetricDimension.create_and_fill(dimension))
          end
        else
          raise CloudwatchToGraphite::ParseError
        end
      end
      if not md.valid?
        raise CloudwatchToGraphite::ParseError
      end
      return md
    end
  end
end
