AWS CloudwatchToGraphite Ruby Gem
=================================

This application will fetch a list of AWS CloudWatch metrics using the Fog
library to connect to the Amazon APIs.  It can parse a list of metric
definitions in either JSON or YAML formats.  It will take the results and
submit them to a Graphite server of your choosing.

- [Fog](https://github.com/fog/fog)
- [Graphite](http://graphite.wikidot.com/)
- [AWS CloudWatch](http://aws.amazon.com/cloudwatch/)

[![Build
Status](https://travis-ci.org/zsprackett/cloudwatchtographite.png?branch=master)](https://travis-ci.org/zsprackett/cloudwatchtographite)
[![Code
Climate](https://codeclimate.com/github/zsprackett/cloudwatchtographite.png)](https://codeclimate.com/github/zsprackett/cloudwatchtographite)


Usage
-----

    Usage: cloudwatch_to_graphite [OPTIONS]
    
      -a, --access-key=KEY             AWS Access Key (Falls back to ENV['AWS_ACCESS_KEY_ID'])
      -s, --secret-key=KEY             AWS Secret Access Key (Falls back to ENV['AWS_SECRET_ACCESS_KEY'])
      -j, --json-metrics=FILE          Path to JSON metrics file
      -y, --yaml-metrics=FILE          Path to YAML metrics file
      -p, --protocol=udp               TCP or UDP (Default: udp)
      -r, --region=us-east-1           AWS Region (Default: us-east-1)
      -g, --graphite-server=host       Graphite Server (Default: localhost)
      -P, --graphite-port=port         Graphite Port (Default: 2003)
      -c, --carbon-prefix              Carbon Prefix (Default: cloudwatch)
      -v, --verbose                    Increase verbosity
      -V, --version                    Print version and exit
      -h, --help                       help

JSON Metrics Definition File
----------------------------

    {
      "metrics": [
        {
          "namespace": "AWS/ELB",
          "metricname": "RequestCount",
          "statistics": [ "Average", "Minimum", "Maximum" ],
          "dimensions": [{
            "name":"LoadBalancerName",
            "value":"MyLoadBalancer"
          }]
        },
        {
          "namespace": "AWS/EC2",
          "metricname": "CPUUtilization",
          "statistics": [ "Average", "Minimum", "Maximum" ],
          "dimensions": [{
            "name":"InstanceId",
            "value":"i-abc123456"
          }]
        }
      ]
    }

YAML Metrics Definition File
----------------------------

    ---
    metrics:
    -
    namespace: AWS/ELB
    metricname: RequestCount
    statistics:
        - Average
        - Minimum
        - Maximum
    dimensions:
        -
        name: LoadBalancerName
        value: MyLoadBalancer
    -
    namespace: AWS/EC2
    metricname: CPUUtilization
    statistics:
        - Average
        - Minimum
        - Maximum
    dimensions:
        -
        name: InstanceId
        value: i-abc123456

Author
------

[S. Zachariah Sprackett](mailto:zac@sprackett.com)
