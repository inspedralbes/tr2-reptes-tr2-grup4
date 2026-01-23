# class Admin < ApplicationRecord
#   has_secure_password

#   def as_user
#     User.find_by(email: email) ||
#       User.create(
#         email: email,
#         username: username,
#         password_digest: password_digest,
#         role: 'admin'
#       )
#   end
# end
