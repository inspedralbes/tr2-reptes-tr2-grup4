class User < ApplicationRecord
  has_secure_password
  has_one :pi

  has_many :students, class_name: "User", foreign_key: "teacher_id", dependent: :nullify
 
  belongs_to :teacher, class_name: "User", optional: true

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true

  enum :role, {
    admin: "admin",
    teacher: "teacher",
    student: "student"
  }
end