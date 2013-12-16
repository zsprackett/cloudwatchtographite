AWS CloudwatchToGraphite Ruby Gem
=================================

This application will fetch a list of AWS CloudWatch metrics using the Fog
library to connect to the Amazon APIs.  It can parse a list of metric
definitions in either JSON or YAML formats.  It will take the results and
submit them to a Graphite server of your choosing.

- [Fog](https://github.com/fog/fog)
- [Graphite](http://graphite.wikidot.com/)
- [AWS CloudWatch](http://aws.amazon.com/cloudwatch/)

[![Build Status](https://travis-ci.org/zsprackett/cloudwatchtographite.png?branch=master)](https://travis-ci.org/zsprackett/cloudwatchtographite)
[![Code Climate](https://codeclimate.com/github/zsprackett/cloudwatchtographite.png)](https://codeclimate.com/github/zsprackett/cloudwatchtographite)
[![Coverage Status](https://coveralls.io/repos/zsprackett/cloudwatchtographite/badge.png)](https://coveralls.io/r/zsprackett/cloudwatchtographite)
[![Dependency Status](https://gemnasium.com/zsprackett/cloudwatchtographite.png)](https://gemnasium.com/zsprackett/cloudwatchtographite)


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

Contributing
------------

* Find something you would like to work on.
  * Look for anything you can help with in the [issue tracker](https://github.com/zsprackett/cloudwatchtographite/issues).
  * Look at the [code quality metrics](https://codeclimate.com/github/zsprackett/cloudwatchtographite) for anything you can help clean up.
  * Look at the [test coverage](https://coveralls.io/r/zsprackett/cloudwatchtographite) for code in need of rspec tests.
  * Do something else cool!
* Fork the project and do your work in a topic branch.
  * Make sure your changes will work on both Ruby 1.9.3 and Ruby 2.0
* Add tests to prove your code works and run all the tests using `bundle exec rake`.
* Rebase your branch against `zsprackett/cloudwatchtographite` to make sure everything is up to date.
* Commit your changes and send a pull request.

Author
------

[S. Zachariah Sprackett](mailto:zac@sprackett.com)

Copyright
---------

(The MIT License)

Copyright (c) 2013 [zsprackett (S. Zachariah Sprackett)](http://github.com/zsprackett)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/zsprackett/cloudwatchtographite/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

