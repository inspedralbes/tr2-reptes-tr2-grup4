puts "Seeding users..."

User.destroy_all

users = [
  { username: "Admin User", email: "admin@school.com", password: "password123", password_confirmation: "password123" },
  { username: "Teacher One", email: "teacher@school.com", password: "password123", password_confirmation: "password123" },
  { username: "Student One", email: "student@school.com", password: "password123", password_confirmation: "password123" },
  { username: "gigapigga", email: "gigapigga@gmail.com", password: "password123", password_confirmation: "password123" }
]

users.each { |u| User.create!(u) }

puts "✅ Seeded #{User.count} users"

# --------------------------------------------------

puts "Seeding PIs..."

Pi.destroy_all

admin_user = User.find_by(username: "Admin User")
teacher_user = User.find_by(username: "Teacher One")
gigapigga = User.find_by(username: "gigapigga")

if admin_user
  Pi.create!(
    description: "Individual support plan for student with reading difficulties.",
    observations: "Student struggles with reading comprehension and focus during lessons.",
    medrec: "No medical diagnosis. Vision test completed.",
    activities: "Daily guided reading, phonics exercises, and one-on-one tutoring.",
    interacttutorial: "Weekly check-ins with tutor and monthly parent meetings.",
    user_id: admin_user.id
  )
  puts "✅ Created PI for Admin User"
end

if teacher_user
  Pi.create!(
    description: "Behavior improvement intervention plan.",
    observations: "Frequent classroom disruptions and difficulty following instructions.",
    medrec: "Diagnosed with ADHD. Medication managed externally.",
    activities: "Positive reinforcement system, structured routines, movement breaks.",
    interacttutorial: "Bi-weekly meetings with school counselor.",
    user_id: teacher_user.id
  )
  puts "✅ Created PI for Teacher One"
end

if gigapigga
  Pi.create!(
    description: "Individual support plan for student with reading difficulties.",
    observations: "Student struggles with reading comprehension and focus during lessons.",
    medrec: "No medical diagnosis. Vision test completed.",
    activities: "Daily guided reading, phonics exercises, and one-on-one tutoring.",
    interacttutorial: "Weekly check-ins with tutor and monthly parent meetings.",
    user_id: gigapigga.id
  )
  puts "✅ Created PI for Admin User"
end

puts "✅ Seeded #{Pi.count} PIs"
