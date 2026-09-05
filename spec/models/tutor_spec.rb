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
end
