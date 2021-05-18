class Attendance < ApplicationRecord
  after_create :new_attending_send

  belongs_to :attending, class_name: "User"
  belongs_to :event

  def new_attending_send
    UserMailer.new_attending_email(self.event.admin, self.attending).deliver_now
  end
end
