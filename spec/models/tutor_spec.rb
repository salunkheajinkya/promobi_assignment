require 'rails_helper'

RSpec.describe Tutor, type: :model do
  subject { create(:tutor) }

  it { should belong_to(:course) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it 'is invalid with a malformed email' do
    tutor = build(:tutor, email: 'not-an-email')
    expect(tutor).not_to be_valid
  end

  describe 'custom validation: name uniqueness scoped to course' do
    context 'negative - same tutor name within the same course' do
      it 'is invalid' do
        course = create(:course, tutors_count: 1)
        create(:tutor, name: 'John Doe', course: course)

        duplicate_tutor = build(:tutor, name: 'John Doe', course: course)
        expect(duplicate_tutor).not_to be_valid
        expect(duplicate_tutor.errors[:name]).to include('already teaches this course')
      end
    end

    context 'positive - same tutor name across different courses' do
      it 'is valid' do
        course_a = create(:course, tutors_count: 1)
        course_b = create(:course, tutors_count: 1)
        create(:tutor, name: 'John Doe', course: course_a)

        tutor_in_other_course = build(:tutor, name: 'John Doe', course: course_b)
        expect(tutor_in_other_course).to be_valid
      end
    end
  end
end