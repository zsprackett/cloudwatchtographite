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
