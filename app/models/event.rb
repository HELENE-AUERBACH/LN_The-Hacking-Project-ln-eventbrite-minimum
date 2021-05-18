class Event < ApplicationRecord
  validates :start_date,
            presence: true
  validate  :start_date_cannot_be_in_the_past
  validates :duration,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validate  :duration_must_be_multiple_of_5
  validates :title,
            length: { minimum: 5, maximum: 140 }
  validates :description,
            length: { minimum: 20, maximum: 1000 }
  validates :price,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }
  validates :location,
            presence: true
  has_many :attendances, dependent: :destroy
  has_many :attendings, through: :attendances
  belongs_to :admin, class_name: "User"

  private

  def start_date_cannot_be_in_the_past
    if start_date.present? && start_date < DateTime.now.in_time_zone
      errors.add(:start_date, "must not to be in the past")
    end
  end

  def duration_must_be_multiple_of_5
    return if !duration.present? || duration <= 0
    errors.add(:duration, "must be a multiple of 5") unless duration % 5 == 0
  end
end
