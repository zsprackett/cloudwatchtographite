# _*_ coding: utf-8 _*_
# frozen_string_literal: true
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
  ].freeze

  STATISTICS = %w(
    Minimum
    Maximum
    Sum
    Average
    SampleCount
  ).freeze

  SETTER_MAPPINGS = {
    'namespace'  => :Namespace=,
    'metricname' => :MetricName=,
    'statistics' => :Statistics=,
    'starttime'  => :StartTime=,
    'endtime'    => :EndTime=,
    'period'     => :Period=,
    'dimensions' => :Dimensions=,
    'unit'       => :Unit=
  }.freeze

  # A hashable representation of an AWS CloudWatch metric
  #
  class MetricDefinition
    attr_reader :Namespace, :MetricName, :Statistics, :Unit, :Period
    extend Hashifiable
    hashify 'Namespace', 'MetricName', 'Statistics', 'StartTime', \
            'EndTime', 'Period', 'Dimensions' # , 'Unit'

    def initialize
      @Unit = UNITS[0]
      @Dimensions = []
      @Statistics = []
      @Period = 60
    end

    def Namespace=(n)
      Validator.string_shorter_than(n, 256)
      @Namespace = n
    end

    def MetricName=(n)
      Validator.string_shorter_than(n, 256)
      @MetricName = n
    end

    def StartTime=(time)
      raise ArgumentTypeError unless time.is_a?(Time)
      @StartTime = time
    end

    def StartTime
      if @StartTime.nil?
        (Time.now - 600).iso8601
      else
        @StartTime.iso8601
      end
    end

    def EndTime=(time)
      raise ArgumentTypeError unless time.is_a?(Time)
      @EndTime = time
    end

    def EndTime
      if @EndTime.nil?
        Time.now.iso8601
      else
        @EndTime.iso8601
      end
    end

    def Period=(n)
      raise ArgumentTypeError unless n.is_a? Integer
      @Period = n
    end

    def Unit=(n)
      raise ArgumentTypeError unless UNITS.include? n
      @Unit = n
    end

    def Dimensions
      @Dimensions.map(&:to_h)
    end

    def add_statistic(n)
      raise ArgumentTypeError unless STATISTICS.include? n
      @Statistics.push(n) unless @Statistics.include? n
    end

    def add_dimension(n)
      if !n.is_a?(MetricDimension)
        raise ArgumentTypeError
      elsif @Dimensions.length >= 10
        raise TooManyDimensionError
      end
      @Dimensions.push(n)
    end

    def valid?
      if @Namespace.nil? || @MetricName.nil? || @Statistics.empty? \
        || @Dimensions.empty? || @Unit.nil?
        false
      else
        true
      end
    end

    def graphite_path(stat)
      path = '%s.%s.%s.%s' % [
        self.Namespace,
        self.MetricName,
        stat,
        @Dimensions.join('.')
      ]
      path.tr('/', '.').downcase
    end

    def self.create_and_fill(definition)
      md = MetricDefinition.new
      definition.each_key do |k|
        populate_metric_definition(
          md, k, definition[k]
        )
      end
      raise ParseError unless md.valid?
      md
    end

    def self.populate_metric_definition(md, key, value)
      case key
      when 'namespace', 'metricname', 'period', 'unit'
        md.send(SETTER_MAPPINGS[key], value)
      when 'starttime', 'endtime'
        begin
          md.send(SETTER_MAPPINGS[key], Time.parse(value))
        rescue ArgumentTypeError
          raise ParseError
        end
      when 'statistics'
        populate_statistics(md, value)
      when 'dimensions'
        populate_dimensions_from_hashes(md, value)
      else
        raise ParseError
      end
    end

    def self.populate_statistics(md, statistics)
      Array(statistics).each do |stat|
        md.add_statistic(stat)
      end
    end

    def self.populate_dimensions_from_hashes(md, dimensions)
      Array(dimensions).each do |dimension|
        md.add_dimension(MetricDimension.create_from_hash(dimension))
      end
    end
  end
end
