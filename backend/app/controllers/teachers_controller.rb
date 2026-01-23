class TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_teacher, only: %i[ show update destroy ]
  
  # Acción para que teachers vean sus estudiantes
  def students
    # Verificar que el usuario sea teacher o admin
    unless current_user&.teacher? || current_user&.admin?
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end
    
    if current_user.admin?
      # Admin ve todos los usuarios que son estudiantes
      students = User.where(role: 'student').includes(:teacher)
    else
      # Teacher ve solo sus propios estudiantes
      students = current_user.students
    end
    
    render json: students.as_json(
      only: [:id, :username, :email],
      include: { teacher: { only: [:id, :username] } }
    ), status: :ok
  end

  # Para que teachers vean documentos de sus estudiantes
  def student_document
    # Verificar que el usuario sea teacher o admin
    unless current_user&.teacher? || current_user&.admin?
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # Verificar permisos
    if current_user.teacher?
      # Teacher solo puede ver sus propios estudiantes
      unless student.teacher_id == current_user.id
        return render json: { error: "Forbidden" }, status: :forbidden
      end
    end
    
    # Admin puede ver cualquier estudiante sin restricción

    pi = Pi.find_by(user_id: student.id)

    sections =
      if pi
        [
          { id: "description", title: "Description", content: pi.description },
          { id: "observations", title: "Observations", content: pi.observations },
          { id: "medrec", title: "Medical Recommendations", content: pi.medrec },
          { id: "activities", title: "Activities", content: pi.activities },
          { id: "interacttutorial", title: "Tutor Interaction", content: pi.interacttutorial },
        ]
      else
        []
      end

    render json: { 
      student: { id: student.id, username: student.username, email: student.email },
      sections: sections 
    }, status: :ok
  end

  # GET /teachers
  def index
    # Solo admin puede ver la lista de todos los teachers
    unless current_user&.admin?
      return render json: { error: "Admin access required" }, status: :unauthorized
    end
    
    @teachers = User.where(role: 'teacher').includes(:students)
    render json: @teachers.as_json(
      only: [:id, :username, :email, :created_at],
      include: { 
        students: { 
          only: [:id, :username, :email] 
        } 
      }
    )
  end

  # GET /teachers/1
  def show
    # Solo admin puede ver detalles de cualquier teacher
    # O un teacher puede ver su propio perfil
    unless current_user&.admin? || (current_user&.teacher? && current_user.id == @teacher.id)
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end
    
    render json: @teacher.as_json(
      only: [:id, :username, :email, :created_at],
      include: { 
        students: { 
          only: [:id, :username, :email] 
        } 
      }
    )
  end

  # POST /teachers (solo para admin crear nuevos teachers)
  def create
    unless current_user&.admin?
      return render json: { error: "Admin access required" }, status: :unauthorized
    end
    
    @teacher = User.new(teacher_params.merge(role: 'teacher'))

    if @teacher.save
      render json: @teacher.as_json(only: [:id, :username, :email]), status: :created
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /teachers/1
  def update
    # Solo admin puede actualizar cualquier teacher
    # O un teacher puede actualizar su propio perfil
    unless current_user&.admin? || (current_user&.teacher? && current_user.id == @teacher.id)
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end
    
    # Evitar que un teacher cambie su propio rol
    params_to_update = teacher_params
    if current_user.teacher? && !current_user.admin?
      params_to_update = params_to_update.except(:role)
    end
    
    if @teacher.update(params_to_update)
      render json: @teacher.as_json(only: [:id, :username, :email])
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  # DELETE /teachers/1
  def destroy
    unless current_user&.admin?
      return render json: { error: "Admin access required" }, status: :unauthorized
    end
    
    # Reasignar estudiantes antes de eliminar
    @teacher.students.update_all(teacher_id: nil)
    
    @teacher.destroy
    render json: { message: "Teacher deleted successfully" }, status: :ok
  end

  # Acción adicional: asignar estudiantes a teachers (solo admin)
  def assign_student
    unless current_user&.admin?
      return render json: { error: "Admin access required" }, status: :unauthorized
    end
    
    teacher = User.find_by(id: params[:teacher_id], role: 'teacher')
    student = User.find_by(id: params[:student_id], role: 'student')
    
    unless teacher && student
      return render json: { error: "Teacher or student not found" }, status: :not_found
    end
    
    if student.update(teacher_id: teacher.id)
      render json: { 
        message: "Student assigned successfully",
        teacher: { id: teacher.id, username: teacher.username },
        student: { id: student.id, username: student.username }
      }, status: :ok
    else
      render json: { error: "Failed to assign student" }, status: :unprocessable_entity
    end
  end

  private
  
  def set_teacher
    @teacher = User.find_by(id: params[:id], role: 'teacher')
    return render json: { error: "Teacher not found" }, status: :not_found unless @teacher
  end

  def teacher_params
    params.require(:teacher).permit(:username, :email, :password, :password_confirmation, :role)
  end
end