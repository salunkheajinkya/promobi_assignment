FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
    duration { "3 months" }

    transient do
      tutors_count { 1 }
    end

    after(:build) do |course, evaluator|
      if course.tutors.empty? && evaluator.tutors_count.to_i.positive?
        evaluator.tutors_count.times do
          course.tutors.build(attributes_for(:tutor))
        end
      end
    end
  end
end
