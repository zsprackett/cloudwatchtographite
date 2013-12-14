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
require_relative './cloudwatchtographite/exception'
require_relative './cloudwatchtographite/version'
require_relative './cloudwatchtographite/metricdefinition'
require_relative './cloudwatchtographite/metricdimension'
require_relative './cloudwatchtographite/loadmetrics'
require 'socket'
require 'fog'
require 'pp'

module CloudwatchToGraphite
  class Base
    attr_accessor :protocol
    attr_accessor :graphite_server
    attr_accessor :graphite_port
    attr_reader   :carbon_prefix

    def initialize(aws_access_key, aws_secret_key, region, verbose=false)
      @protocol        = 'udp'
      @carbon_prefix   = 'cloudwatch'
      @graphite_server = 'localhost'
      @graphite_port   = 2003
      @verbose         = verbose

      debug_log "Fog setting up for region %s" % region

      @cloudwatch = Fog::AWS::CloudWatch.new(
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_key,
        :region => region
      )
    end

    def send_udp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      debug_log "Attempting to send %d bytes to %s:%d via udp" % [
        contents.length, @graphite_server, @graphite_port
      ]

      begin
        sock = UDPSocket.open
        sock.send(contents, 0, @graphite_server, @graphite_port)
        retval = true
      rescue Exception => e
        debug_log "Caught exception! [#{e}]"
        retval = false
      ensure
        sock.close if sock
      end
      retval
    end

    def send_tcp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      debug_log "Attempting to send %d bytes to %s:%d via tcp" % [
        contents.length, @graphite_server, @graphite_port
      ]

      retval = false
      begin
        sock = TCPSocket.open(@graphite_server, @graphite_port)
        sock.print(contents)
        retval = true
      rescue Exception => e
        debug_log "Caught exception! [#{e}]"
      ensure
        sock.close if sock
      end
      retval
    end

    def get_datapoints(metrics)
      if metrics.kind_of?(CloudwatchToGraphite::MetricDefinition)
        raise CloudwatchToGraphite::ArgumentTypeError
      end

      ret = []
      metrics.each do |m|
        debug_log "Sending:\n%s" % PP.pp(m.to_h, "")
        begin
          data_points = @cloudwatch.get_metric_statistics(
            m.to_h
          ).body['GetMetricStatisticsResult']['Datapoints']
          debug_log "Received:\n%s" % PP.pp(data_points, "")
          data_points = order_data_points(data_points)

          m.Statistics.each do |stat|
            name = "%s.%s" % [ @carbon_prefix,  m.graphite_path(stat) ]

            data_points.each do |d|
              ret.push "%s %s %d" % [ name, d[stat], d['Timestamp'].utc.to_i ]
            end
          end
        rescue Excon::Errors::SocketError, Excon::Errors::BadRequest => e
          warn "[Error in CloudWatch call] %s" % e.message
        rescue Excon::Errors::Forbidden
          warn "[Error in CloudWatch call] permission denied - check keys!"
        end
      end

      debug_log "Returning:\n%s" % PP.pp(ret, "")
      ret
    end

    def fetch_and_forward(metrics)
      results = get_datapoints(metrics)
      if results.length == 0
        false
      else
        case @protocol
        when 'tcp'
          send_tcp(results)
        when 'udp'
          send_udp(results)
        else
          warn "Unknown protocol %s" % @protocol
          raise CloudwatchToGraphite::ProtocolError
        end
      end
    end

    def carbon_prefix=(p)
      if not p.kind_of?(String)
        raise CloudwatchToGraphite::ArgumentTypeError
      elsif p.length <= 0
        raise CloudwatchToGraphite::ArgumentLengthError
      end
      @carbon_prefix=p
    end

    private
    def order_data_points(data_points)
      if data_points.nil?
        data_points = []
      else
        data_points = Array(data_points)
      end

      if data_points.length == 0
        warn "No data points!"
        data_points
      else
        data_points = data_points.sort_by {|array| array['Timestamp'] }
      end
    end

    def debug_log(s)
      if @verbose
        warn s
      end
    end
  end
end
