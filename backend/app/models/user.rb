class User < ApplicationRecord
  has_secure_password
  has_one :pi

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true
end
