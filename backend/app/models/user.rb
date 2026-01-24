class User < ApplicationRecord
  has_secure_password
  has_one :pi

  has_many :students, class_name: "User", foreign_key: "teacher_id"
  belongs_to :teacher, class_name: "User", optional: true

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true
  validates :role, inclusion: { in: %w(student teacher admin) }

  before_validation :set_default_role

  # Role validation methods
  def student?
    role == "student"
  end

  def teacher?
    role == "teacher"
  end

  def admin?
    role == "admin"
  end

  private

  def set_default_role
    self.role ||= "student"
  end
end