puts "🌱 Seeding database..."

# --------------------------------------------------
# LIMPIEZA
# --------------------------------------------------
puts "🧹 Cleaning database..."

Pi.destroy_all
User.destroy_all

# --------------------------------------------------
# USUARIOS
# --------------------------------------------------
puts "👤 Seeding users..."

users = [
  {
    username: "Admin User",
    email: "admin@school.com",
    role: "admin",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    username: "Teacher One",
    email: "teacher@school.com",
    role: "teacher",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    username: "Student One",
    email: "student@school.com",
    role: "student",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    username: "gigapigga",
    email: "gigapigga@gmail.com",
    role: "student",
    password: "password123",
    password_confirmation: "password123"
  }
]

users.each { |u| User.create!(u) }

puts "✅ Users created: #{User.count}"

# --------------------------------------------------
# RELACIÓN PROFESOR → ALUMNOS
# --------------------------------------------------
puts "🔗 Assigning students to teacher..."

teacher = User.find_by!(role: "teacher")
student_1 = User.find_by!(username: "Student One")
student_2 = User.find_by!(username: "gigapigga")

student_1.update!(teacher: teacher)
student_2.update!(teacher: teacher)

puts "✅ #{teacher.username} assigned to students"

# --------------------------------------------------
# PIs
# --------------------------------------------------
puts "📄 Seeding PIs..."

admin_user   = User.find_by!(username: "Admin User")
teacher_user = User.find_by!(username: "Teacher One")
student_user = User.find_by!(username: "gigapigga")


Pi.create!(
  user: student_user,
  description: "Student PI description",
  observations: "Student observations",
  medrec: "Student medical record",
  activities: "Student activities",
  interacttutorial: "Student tutorial interactions"
)

puts "✅ PIs created: #{Pi.count}"

puts "🎉 Seeding finished successfully!"
