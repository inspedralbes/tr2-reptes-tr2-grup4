# class Teacher < ApplicationRecord
#     has_secure_password

#     has_many :students, class_name: "User", foreign_key: "teacher_id"
#         # belongs_to :teacher, class_name: "User", optional: true

#     validates :email, presence: true, uniqueness: true
#     validates :username, presence: true

#     def as_user
#         User.find_by(email: email) ||
#             User.create(
#                 email: email,
#                 username: username,
#                 password_digest: password_digest,
#                 role: 'teacher'
#             )
#     end
# end
