# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding users..."

User.destroy_all

users = [
  { username: "Admin User", email: "admin@school.com", password: "password123", password_confirmation: "password123" },
  { username: "Teacher One", email: "teacher@school.com", password: "password123", password_confirmation: "password123" },
  { username: "Student One", email: "student@school.com", password: "password123", password_confirmation: "password123" }
]

users.each { |u| User.create!(u) }

puts "✅ Seeded #{User.count} users"
