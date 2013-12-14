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
            load_content(contents)
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
          load_content(contents)
        rescue Exception
          warn "Failed to parse %s" % filename
          []
        end
      end
    end

    private
    def self.load_content(contents, strict=false)
      metrics = []
      unless contents.kind_of?(Hash) and contents.has_key?('metrics') and contents['metrics'].kind_of?(Array)
        raise CloudwatchToGraphite::ArgumentTypeError
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
