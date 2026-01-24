puts "Seeding users..."

# Destroy dependent records first (due to foreign key constraints)
PdfUpload.destroy_all
Pi.destroy_all
User.destroy_all

users = [
  { username: "Admin User", email: "admin@school.com", password: "password123", password_confirmation: "password123", role: "admin" },
  { username: "Teacher One", email: "teacher@school.com", password: "password123", password_confirmation: "password123", role: "teacher" },
  { username: "Student One", email: "student@school.com", password: "password123", password_confirmation: "password123", role: "student" },
  { username: "gigapigga", email: "gigapigga@gmail.com", password: "password123", password_confirmation: "password123", role: "student" }
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
    description: "This is Admin User. Comprehensive individualized support plan designed to address persistent reading difficulties that have been impacting academic performance across multiple subjects. The student demonstrates significant challenges with decoding unfamiliar words, maintaining reading fluency, and comprehending age-appropriate texts. This plan focuses on building foundational literacy skills while also developing compensatory strategies to help the student access the general curriculum more effectively.",
    observations: "Student shows difficulty staying focused during independent reading activities, often becomes distracted after 5-10 minutes of reading. Reading comprehension assessments reveal strong oral comprehension but significant gap in written text understanding. Student avoids reading aloud in class due to frustration. However, shows strong listening comprehension and can retell stories accurately when content is presented verbally. Progress has been noted in sight word recognition over the past semester.",
    medrec: "No formal medical diagnosis related to learning difficulties. Comprehensive vision screening completed on September 15, 2025 - normal visual acuity bilaterally, no need for corrective lenses. Hearing screening passed within normal limits. Family history of dyslexia on maternal side. Parents have been advised to pursue formal psychoeducational evaluation if difficulties persist despite intervention. Annual vision and hearing screenings recommended.",
    activities: "Daily 30-minute guided reading sessions with specialized literacy interventionist using Orton-Gillingham approach. Phonics instruction focusing on multi-syllabic word patterns and morphemes. Weekly 45-minute one-on-one tutoring sessions focusing on reading fluency through repeated reading protocols. Use of audiobooks and text-to-speech technology to access grade-level content. Daily vocabulary building activities using word maps and semantic gradients. Parent-implemented home reading program with decodable texts provided weekly.",
    interacttutorial: "Weekly 30-minute check-ins with assigned tutor to monitor progress and adjust intervention intensity. Monthly collaborative meetings with parents, classroom teacher, and interventionist to review progress data and discuss home support strategies. Quarterly review meetings with school psychologist to evaluate need for further assessment. Communication log maintained between home and school for daily updates on reading practice and observations.",
    user_id: admin_user.id
  )
  puts "✅ Created PI for Admin User"
end

if teacher_user
  Pi.create!(
    description: "Behavior intervention plan developed to address pattern of classroom disruptions and non-compliance that has been interfering with student's own learning as well as that of peers. The plan incorporates positive behavioral supports, structured routines, and self-regulation strategies. Goal is to increase prosocial behaviors and independent functioning while reducing frequency and intensity of disruptive incidents through proactive interventions and consistent consequences.",
    observations: "Student frequently calls out during instruction without raising hand, leaves seat without permission, and has difficulty following multi-step directions. Patterns observed: behaviors intensify during transitions, after recess, and when facing tasks perceived as difficult. When calm and engaged, student demonstrates age-appropriate academic skills. Strong social motivation observed - behaviors often seek peer attention. Student can identify triggers but struggles to use replacement behaviors independently. Improvement noted when classroom environment is highly structured with clear expectations.",
    medrec: "Formal diagnosis of Attention-Deficit/Hyperactivity Disorder (Combined Type) confirmed by pediatric neurologist on March 10, 2024. Currently managed with stimulant medication prescribed by primary care physician, administered at home before school. 504 Plan in place with accommodations including extended time on tests, preferential seating, and movement breaks. Medication effectiveness monitored through daily report cards. No reported side effects affecting appetite or sleep. Annual follow-up scheduled for March 2026.",
    activities: "Implementation of positive reinforcement behavior system with tangible rewards earned for meeting daily behavior goals. Structured visual schedule posted in classroom with countdowns for transitions. Scheduled movement breaks every 45 minutes to address sensory needs and maintain attention. Use of break card allowing student to request self-regulation breaks when feeling overwhelmed. participation in school-wide social-emotional learning curriculum (Second Step). Weekly 30-minute sessions with school counselor focusing on emotional regulation and social skills. Pre-teaching of expectations before special events or schedule changes.",
    interacttutorial: "Bi-weekly 45-minute meetings with school counselor to review behavior data and develop coping strategies. Weekly 15-minute check-ins with homeroom teacher to discuss progress and adjust goals. Monthly collaboration meetings with parents, teacher, counselor, and 504 coordinator to review behavior report cards and medication effectiveness. Daily behavior report sent home for parent review and signature. Crisis intervention protocol established for instances of severe behavioral escalation. Communication app (ClassDojo) used for real-time updates between home and school.",
    user_id: teacher_user.id
  )
  puts "✅ Created PI for Teacher One"
end

if gigapigga
  Pi.create!(
    description: "Individualized academic support plan targeting significant gaps in mathematical reasoning and calculation skills. The student performs significantly below grade level in mathematics despite adequate cognitive abilities and strong performance in language arts. This plan implements systematic explicit instruction in mathematical concepts, procedural fluency practice, and real-world application activities to build mathematical understanding and confidence.",
    observations: "Student demonstrates difficulty with multi-digit multiplication and division, fraction operations, and word problem comprehension. Calculations frequently show carelessness errors despite understanding of underlying concepts. Student exhibits math anxiety, often stating 'I'm just not a math person.' When given additional time and scaffolded support, student successfully completes grade-level work. Shows strength in logical reasoning when problems are presented visually or with manipulatives. Avoids math homework and becomes tearful when asked to complete math assignments.",
    medrec: "No specific learning disability identified. Math anxiety assessment completed by school psychologist indicates moderate to severe mathematics anxiety affecting performance. Vision screening normal, hearing screening normal. Previous math intervention in 4th grade showed temporary gains that were not maintained. Parents report similar math difficulties in family members. Recommended: continued intervention with focus on building mathematical confidence and reducing anxiety alongside skill instruction.",
    activities: "Daily 45-minute small group math instruction using explicit teaching model with systematic practice. Use of manipulatives and visual models to build conceptual understanding before moving to abstract representations. Weekly 30-minute one-on-one sessions targeting specific skill gaps identified through diagnostic assessment. Integration of real-world math problems to increase motivation and show practical applications. Use of calculator accommodation for in-class assignments to reduce frustration while focusing on problem-solving skills. Math fact fluency practice using technology-based program (XtraMath) for 10 minutes daily at home.",
    interacttutorial: "Weekly check-ins with math interventionist to review progress data and adjust instruction. Monthly collaborative meetings with parents and classroom teacher to discuss homework completion, attitude toward math, and upcoming curriculum content. Quarterly benchmark assessments to measure progress toward grade-level standards. Daily communication through agenda notebook for tracking homework completion and behavioral observations. End-of-unit conferences with student to celebrate progress and set goals for next unit. Parent workshop scheduled for November to provide strategies for supporting math at home.",
    user_id: gigapigga.id
  )
  puts "✅ Created PI for gigapigga"
end

puts "✅ Seeded #{Pi.count} PIs"
