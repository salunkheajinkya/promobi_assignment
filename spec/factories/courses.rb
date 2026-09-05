FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
    duration { "3 months" }
  end
end
