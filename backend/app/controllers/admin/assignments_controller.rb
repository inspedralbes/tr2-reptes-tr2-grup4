module Admin
  class AssignmentsController < ApplicationController
    # Si usas cookies/sesión
    # protect_from_forgery with: :null_session

    def index
      students = User
        .where(role: "student")
        .includes(:teacher)

      teachers = User.where(role: "teacher")

      render json: {
        students: students.as_json(
          only: [:id, :username, :email],
          include: {
            teacher: {
              only: [:id, :username]
            }
          }
        ),
        teachers: teachers.as_json(
          only: [:id, :username]
        )
      }
    end

    def update
      student = User.find(params[:student_id])
      teacher = User.find(params[:teacher_id])

      student.update!(teacher: teacher)

      render json: { success: true }
    end
  end
end
