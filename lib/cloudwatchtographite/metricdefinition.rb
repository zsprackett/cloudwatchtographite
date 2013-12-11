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

  class MetricDefinition
    attr_reader :Namespace, :MetricName, :Statistics, :Unit, :Period
    extend Hashifiable
    hashify :Namespace, :MetricName, :Statistics, :StartTime, :EndTime, :Period, :Dimensions#, :Unit

    def initialize
      @Unit = UNITS[0]
      @Dimensions = []
      @Statistics = []
      @Period = 60
    end

    def Namespace=(n)
      if not n.kind_of?(String) or n.length >= 256
        raise ArgumentError
      end
      @Namespace=n
    end

    def MetricName=(n)
      if not n.kind_of?(String) or n.length >= 256
        raise ArgumentError
      end
      @MetricName=n
    end

    def StartTime=(time)
      raise ArgumentError unless time.kind_of?(Time)
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
      raise ArgumentError unless time.kind_of?(Time)
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
      raise ArgumentError unless n.kind_of? Integer
      @Period = n
    end

    def Unit=(n)
      raise ArgumentError unless UNITS.include? n
      @Unit = n
    end

    def Dimensions
      @Dimensions.map(&:to_stringy_h)
    end

    def add_statistic(n)
      raise ArgumentError unless STATISTICS.include? n
      if not @Statistics.include? n
        @Statistics.push(n)
      end
    end

    def add_dimension(name, value)
      # maximum of 10 dimensions
      raise ArgumentError unless @Dimensions.length < 10
      d = MetricDimension.new(name, value)
      @Dimensions.push(d)
    end

    def valid?
      if @Namespace.nil? or @MetricName.nil? or @Statistics.empty? or @Dimensions.empty? or @Unit.nil?
        false
      else
        true
      end
    end

    def graphite_path(stat)
     path = "%s.%s.%s" % [self.Namespace, self.MetricName, stat]
     @Dimensions.each do |d|
       path += "." + d.Value
     end
     path.gsub('/', '.').downcase
    end

    def self.create_and_fill(definition)
      md = MetricDefinition.new
      definition.each_key do |k|
        case k
        when 'namespace'
          md.Namespace = definition[k]
        when 'metricname'
          md.MetricName = definition[k]
        when 'starttime'
          begin
            md.StartTime = Time.parse(definition[k])
          rescue ArgumentError
            warn "Ignoring malformed starttime of #{definition[k]}"
          end
        when 'endtime'
          begin
            md.EndTime = Time.parse(definition[k])
          rescue ArgumentError
            warn "Ignoring malformed endtime of #{definition[k]}"
          end
        when 'period'
          md.Period = definition[k]
        when 'unit'
          md.Unit = definition[k]
        when 'statistics'
          if not definition[k].kind_of?(Array)
            definition[k] = [ definition[k] ]
          end
          definition[k].each do |stat|
            md.add_statistic(stat)
          end
        when 'dimensions'
          if not definition[k].kind_of?(Array)
            definition[k] = [ definition[k] ]
          end
          definition[k].each do |dimension|
            if dimension.has_key?('name') and dimension.has_key?('value')
              md.add_dimension(dimension['name'], dimension['value'])
            else
              warn "Ignoring unknown dimension "
            end
          end
        else
          warn "Ignoring unknown metric definition #{key}"
        end
      end

      if md.valid?
        md
      else
        false
      end
    end
  end
end
