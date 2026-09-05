FactoryBot.define do
  factory :tutor do
    name { Faker::Name.name }
    sequence(:email) { |n| "tutor#{n}@example.com" }
    course
  end
end
