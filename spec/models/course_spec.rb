require 'rails_helper'

RSpec.describe Course, type: :model do
  it { should have_many(:tutors).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:duration) }
  it { should validate_uniqueness_of(:name) }

  it 'accepts nested attributes for tutors' do
    course = build(:course, tutors_attributes: [{ name: 'Alice', email: 'a@x.com' }])
    expect(course.save).to be true
    expect(course.tutors.count).to eq(1)
  end
end
