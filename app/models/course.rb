class Course < ApplicationRecord
  has_many :tutors, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :duration, presence: true

  accepts_nested_attributes_for :tutors
end