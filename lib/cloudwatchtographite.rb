# _*_ coding: utf-8 _*_
#
# Author:: S. Zachariah Sprackett <zac@sprackett.com>
# License:: The MIT License (MIT)
# Copyright:: Copyright (C) 2013 - S. Zachariah Sprackett <zac@sprackett.com>
#
require_relative './cloudwatchtographite/exception'
require_relative './cloudwatchtographite/version'
require_relative './cloudwatchtographite/metricdefinition'
require_relative './cloudwatchtographite/metricdimension'
require_relative './cloudwatchtographite/loadmetrics'
require_relative './cloudwatchtographite/validator'
require 'socket'
require 'fog'
require 'pp'

module CloudwatchToGraphite
  # This class is responsible for retrieving metrics from CloudWatch and
  # sending the results to a Graphite server.
  class Base
    attr_accessor :protocol
    attr_accessor :graphite_server
    attr_accessor :graphite_port
    attr_reader   :carbon_prefix

    # Initialize the CloudwatchToGraphite::Base object.
    # aws_access_key:: The AWS user key
    # aws_secret_key:: The AWS secret
    # region:: The AWS region (eg: us-west-1)
    # verbose:: boolean to enable verbose output
    #
    def initialize(aws_access_key, aws_secret_key, region, verbose=false)
      @protocol        = 'udp'
      @carbon_prefix   = 'cloudwatch'
      @graphite_server = 'localhost'
      @graphite_port   = 2003
      @verbose         = verbose

      debug_log "Fog setting up for region #{region}"

      @cloudwatch = Fog::AWS::CloudWatch.new(
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_key,
        :region => region
      )
    end

    # Send data to a Graphite server via the UDP protocol
    # contents:: a string or array containing the contents to send
    #
    def send_udp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      debug_log "Attempting to send #{contents.length}  bytes " +
        "to #{@graphite_server}:#{@graphite_port} via udp"

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

    # Send data to a Graphite server via the TCP protocol
    # contents:: a string or array containing the contents to send
    #
    def send_tcp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      debug_log "Attempting to send #{contents.length}  bytes " +
        "to #{@graphite_server}:#{@graphite_port} via tcp"

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

    def retrieve_datapoints(metrics)
      ret = []
      Array(metrics).each do |m|
        begin
          ret.concat retrieve_one_datapoint(m)
        rescue Excon::Errors::SocketError, Excon::Errors::BadRequest => e
          warn "[Error in CloudWatch call] #{e.message}"
        rescue Excon::Errors::Forbidden
          warn "[Error in CloudWatch call] permission denied - check keys!"
        end
      end
      ret
    end

    def retrieve_one_datapoint(metric)
      debug_log "Sending to CloudWatch:"
      debug_object metric.to_h
      data_points = @cloudwatch.get_metric_statistics(
        metric.to_h
      ).body['GetMetricStatisticsResult']['Datapoints']
      debug_log "Received from CloudWatch:"
      debug_object data_points

      return retrieve_statistics(metric, order_data_points(data_points))
    end

    def retrieve_statistics(metric, data_points)
      ret = []
      metric.Statistics.each do |stat|
        name = "#{@carbon_prefix}.#{metric.graphite_path(stat)}"
        data_points.each do |d|
          ret.push "#{name} #{d[stat]} #{d['Timestamp'].utc.to_i}"
        end
      end
      debug_log "Returning Statistics:"
      debug_object ret
      ret
    end

    def fetch_and_forward(metrics)
      results = retrieve_datapoints(metrics)
      if results.length == 0
        false
      else
        case @protocol
        when 'tcp'
          send_tcp(results)
        when 'udp'
          send_udp(results)
        else
          debug_log "Unknown protocol #{@protocol}"
          raise ProtocolError
        end
      end
    end

    # set the carbon prefix
    # p:: the string prefix to use
    def carbon_prefix=(p)
      Validator::string_longer_than(p, 0)
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

    def debug_object(s)
      if @verbose
        warn PP.pp(s, "")
      end
    end
  end
end
