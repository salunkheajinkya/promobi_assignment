class Course < ApplicationRecord
  has_many :tutors, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :duration, presence: true
  validate :must_have_at_least_one_tutor, on: :create
  validate :duration_format_valid
  validate :no_duplicate_tutor_names_in_batch

  accepts_nested_attributes_for :tutors

  private

  def must_have_at_least_one_tutor
    if tutors.empty?
      errors.add(:base, "Course must have at least one tutor")
    end
  end

  def duration_format_valid
    unless duration.to_s.match?(/\A\d+\s+(day|days|week|weeks|month|months|year|years)\z/i)
      errors.add(:duration, "must be a number followed by day(s)/week(s)/month(s)/year(s), e.g. '3 months'")
    end
  end

  def no_duplicate_tutor_names_in_batch
    names = tutors.reject(&:marked_for_destruction?).map { |t| t.name&.strip&.downcase }.compact
    if names.size != names.uniq.size
      errors.add(:base, "Tutors in the same course must have unique names")
    end
  end
end