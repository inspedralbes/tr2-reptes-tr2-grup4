class User < ApplicationRecord
  has_secure_password

  has_one :pi, dependent: :destroy

  belongs_to :teacher, class_name: "User", optional: true
  has_many :students, class_name: "User", foreign_key: "teacher_id"

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true
  validates :role, inclusion: { in: %w(student teacher admin) }

  before_validation :set_default_role

  def teacher?
    role == "teacher"
  end

  def admin?
    role == "admin"
  end

  def student?
    role == "student"
  end

  private

  def set_default_role
    self.role ||= "student"
  end
end
