class User < ApplicationRecord
  after_create :welcome_send

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: /\A[^@\s]+@yopmail\.com\z/i, message: "Recheck your email adress please!" }
  validates :encrypted_password,
            presence: true,
            length: { minimum: 6 }
  validates :description,
            length: { minimum: 5 },
            presence: true
  validates :first_name,
            length: { minimum: 2 },
            presence: true
  validates :last_name,
            length: { minimum: 2 },
            presence: true
  validates_each :first_name, :last_name do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
  has_many :events_to_administrate, foreign_key: 'admin_id', class_name: "Event", dependent: :destroy
  has_many :attendances, foreign_key: 'attending_id', class_name: "Attendance", dependent: :destroy
  has_many :events_to_attend_in, through: :attendances

  def welcome_send
    UserMailer.welcome_email(self).deliver_now
  end
end
