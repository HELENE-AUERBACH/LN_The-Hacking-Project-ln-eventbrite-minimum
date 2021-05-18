class Attendance < ApplicationRecord
  belongs_to :attending, class_name: "User"
  belongs_to :event
end
