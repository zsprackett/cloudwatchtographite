FactoryGirl.define do
  factory :metricdefinition, :class => CloudwatchToGraphite::MetricDefinition do
    sequence(:MetricName) { |n| "metricname#{n}" }
    sequence(:Namespace) { |n| "namespace#{n}" }
    Period 90
    Unit "None"
    after(:build) do |definition, _evaluator|
      definition.add_statistic("Sum")
      definition.add_statistic("Average")
    end
  end
end
