require 'json'
require 'yaml'

module CloudwatchToGraphite
  class LoadMetrics
    def self.from_json_file(filename)
      if not File.readable?(filename)
        warn "Unable to read %s" % filename
        []
      else
        File.open(filename, 'r') do |f|
          begin
            contents = JSON.load(f)
            self._load_content(contents)
          rescue Exception
            warn "Failed to parse %s" % filename
            []
          end
        end
      end
    end

    def self.from_yaml_file(filename)
      if not File.readable?(filename)
        warn "Unable to read %s" % filename
        []
      else
        begin
          contents = YAML.load_file(filename)
          self._load_content(contents)
        rescue Exception
          warn "Failed to parse %s" % filename
          []
        end
      end
    end

    def self._load_content(contents)
      metrics = []
      unless contents.kind_of?(Hash) and contents.has_key?('metrics') and contents['metrics'].kind_of?(Array)
        warn "Metrics file does not contain metrics!"
        []
      else
        contents['metrics'].each do |m|
          parsed = CloudwatchToGraphite::MetricDefinition::create_and_fill m
          if (parsed != false)
            metrics.push(parsed)
          else
            warn "Failed to parse #{m}."
          end
        end
        metrics
      end
    end
  end
end
