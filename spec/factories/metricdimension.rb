# frozen_string_literal: true
FactoryGirl.define do
  factory :metricdimension, class: CloudwatchToGraphite::MetricDimension do
    sequence(:Name) { |n| "name#{n}" }
    sequence(:Value) { |n| "value#{n}" }
  end
end
