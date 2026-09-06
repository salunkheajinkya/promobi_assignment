require 'rails_helper'

RSpec.describe Course, type: :model do
  subject { create(:course) }

  it { should have_many(:tutors).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:duration) }
  it { should validate_uniqueness_of(:name) }

  it 'accepts nested attributes for tutors' do
    course = build(:course, tutors_count: 0, tutors_attributes: [{ name: 'Alice', email: 'a@x.com' }])
    expect(course.save).to be true
    expect(course.tutors.count).to eq(1)
  end

  describe 'custom validation: must_have_at_least_one_tutor' do
    context 'positive - course has at least one tutor' do
      it 'is valid' do
        course = build(:course, tutors_count: 1)
        expect(course).to be_valid
      end
    end

    context 'negative - course has zero tutors' do
      it 'is invalid' do
        course = build(:course, tutors_count: 0)
        expect(course).not_to be_valid
        expect(course.errors[:base]).to include('Course must have at least one tutor')
      end
    end
  end

  describe 'custom validation: duration_format_valid' do
    context 'positive - valid duration formats' do
      %w[1\ day 3\ days 2\ weeks 6\ months 1\ year].each do |valid_duration|
        it "accepts '#{valid_duration}'" do
          course = build(:course, duration: valid_duration)
          expect(course).to be_valid
        end
      end
    end

    context 'negative - invalid duration formats' do
      ['three months', '5', 'months', '5x months', ''].each do |invalid_duration|
        it "rejects '#{invalid_duration}'" do
          course = build(:course, duration: invalid_duration)
          expect(course).not_to be_valid
        end
      end

      it 'includes a helpful error message' do
        course = build(:course, duration: 'garbage')
        course.valid?
        expect(course.errors[:duration]).to include(
          "must be a number followed by day(s)/week(s)/month(s)/year(s), e.g. '3 months'"
        )
      end
    end
  end
end