class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def assignments
    students = User.where(role: "student").includes(:teacher)
    teachers = User.where(role: "teacher")

    render json: {
      students: students.map { |s|
        {
          id: s.id,
          username: s.username,
          email: s.email,
          teacher: s.teacher ? { id: s.teacher.id, username: s.teacher.username } : nil
        }
      },
      teachers: teachers.map { |t|
        {
          id: t.id,
          username: t.username,
          email: t.email
        }
      }
    }
  end

  def update_assignment
    student = User.find(params[:id])
    
    unless student.role == "student"
      render json: { error: "User is not a student" }, status: :bad_request
      return
    end

    if params[:teacher_id].present?
      teacher = User.find(params[:teacher_id])
      
      unless teacher.role == "teacher"
        render json: { error: "User is not a teacher" }, status: :bad_request
        return
      end

      student.update(teacher_id: teacher.id)
    else
      student.update(teacher_id: nil)
    end

    render json: { success: true, student: student }
  end
end
