module CloudwatchToGraphite
  class VERSION
    MAJOR = 0
    MINOR = 0
    PATCH = 0
    BUILD = 'pre1'

    STRING = [MAJOR, MINOR, PATCH].compact.join('.') + (BUILD.empty? ? '' : ".#{BUILD}")
  end
end
