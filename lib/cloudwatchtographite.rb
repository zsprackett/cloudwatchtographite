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
    attr_accessor :carbon_prefix
    attr_accessor :graphite_server
    attr_accessor :graphite_port

    def initialize(aws_access_key, aws_secret_key, region, verbose=false)
      @protocol        = 'udp'
      @carbon_prefix   = 'cloudwatch'
      @graphite_server = 'localhost'
      @graphite_port   = 2003
      @verbose         = verbose

      warn "Fog setting up for region %s" % region if @verbose

      @cloudwatch = Fog::AWS::CloudWatch.new(
        :aws_access_key_id => aws_access_key,
        :aws_secret_access_key => aws_secret_key,
        :region => region
      )
    end

    def send_udp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      warn "Attempting to send %d bytes to %s:%d via udp" % [
        contents.length, @graphite_server, @graphite_port
      ] if @verbose

      begin
        sock = UDPSocket.open
        sock.send(contents, 0, @graphite_server, @graphite_port)
        retval = true
      rescue Exception => e
        warn "Caught exception! [#{e}]" if @verbose
        retval = false
      ensure
        sock.close if sock
      end
      retval
    end

    def send_tcp(contents)
      sock = nil
      contents = contents.join("\n") if contents.kind_of?(Array)

      warn "Attempting to send %d bytes to %s:%d via tcp" % [
        contents.length, @graphite_server, @graphite_port
      ] if @verbose

      begin
        sock = TCPSocket.open(@graphite_server, @graphite_port)
        sock.print(contents)
        retval = true
      rescue Exception => e
        warn "Caught exception! [#{e}]" if @verbose
        retval = false
      ensure
        sock.close if sock
      end
      retval
    end

    def get_metrics(metrics)
      if metrics.kind_of?(CloudwatchToGraphite::MetricDefinition)
        raise ArgumentError
      end

      ret = []
      metrics.each do |m|
        data_points = []
        warn "Sending:\n%s" % PP.pp(m.to_stringy_h, "") if @verbose
        begin
          data_points = @cloudwatch.get_metric_statistics(
            m.to_stringy_h
          ).body['GetMetricStatisticsResult']['Datapoints']
        rescue Excon::Errors::SocketError => e
          warn "Socket error #{e}"
        rescue Excon::Errors::BadRequest => e
          warn "Bad request #{e}"
        end
        warn "Received:\n%s" % PP.pp(data_points, "") if @verbose

        if not data_points.kind_of?(Array)
          data_points = [ data_points ]
        elsif data_points.length == 0
          warn "No data points!"
        else
          # sort in chronological order
          data_points = data_points.sort_by {|array| array['Timestamp'] }
        end

        # if we aren't already an array, become one
        m.Statistics.each do |stat|
          name = @carbon_prefix.empty? ? '' : "#{@carbon_prefix}."
          name += m.graphite_path(stat)

          data_points.each do |d|
            ret.push "%s %s %d" % [ name, d[stat], d['Timestamp'].utc.to_i ]
          end
        end
      end
      warn "Returning:\n%s" % PP.pp(ret, "") if @verbose
      ret
    end

    def fetch_and_forward(metrics)
      results = self.get_metrics(metrics)
      if results.length == 0
        return false
      else
        case @protocol
        when 'tcp'
          return self.send_tcp(results)
        when 'udp'
          return self.send_udp(results)
        else
          warn "Unknown protocol %s" % @protocol
          return false
        end
      end
    end
  end
end
