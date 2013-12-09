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
      @StartTime=time.iso8601
    end

    def StartTime
      if @StartTime.nil?
        return (Time.now-600).iso8601
      else
        return @StartTime
      end
    end

    def EndTime=(time)
      raise ArgumentError unless time.kind_of?(Time)
      @EndTime=time.iso8601
    end

    def EndTime
      if @EndTime.nil?
        return Time.now.iso8601
      else
        return @EndTime
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
      return if @Statistics.include? n
      @Statistics.push(n)
    end

    def add_dimension(name, value)
      # maximum of 10 dimensions
      raise ArgumentError unless @Dimensions.length < 10
      d = MetricDimension.new(name, value)
      @Dimensions.push(d)
    end

    def valid?
      if @Namespace.nil? or @MetricName.nil? or @Statistics.empty? or @Dimensions.empty? or @Unit.nil?
        return false
      else
        return true
      end
    end

    def graphite_path(stat)
     path = "%s.%s.%s" % [self.Namespace, self.MetricName, stat]
     @Dimensions.each do |d|
       path += "." + d.Value
     end
     return path.gsub('/', '.').downcase
    end

    def self.create_and_fill(definition)
      md = MetricDefinition.new
      # FIXME: add start and end time parsing
      definition.each_key do |k|
        case k
        when 'namespace'
          md.Namespace = definition[k]
        when 'metricname'
          md.MetricName = definition[k]
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
            md.add_dimension(dimension['name'], dimension['value'])
          end
        else
          warn "Ignoring unknown metric definition key #{key}"
        end
      end

      if md.valid?
        return md
      else
        return false
      end
    end
  end
end
