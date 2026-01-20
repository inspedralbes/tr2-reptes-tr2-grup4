class TeachersController < ApplicationController
  #before_action :set_teacher, only: %i[ show update destroy ]


  def students
    user = User.find_by(id: session[:user_id])
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    # TEMPORARY (until you wire real relation):
    # Return all users as "students" just to prove endpoint works.
    render json: User.all.as_json(only: [:id, :username, :email]), status: :ok
  end

  def student_document
    user = User.find_by(id: session[:user_id])
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # Basic safety: only allow the teacher to see their own students (uses teacher_id model)
    # If you haven't wired teacher_id yet, comment this check out for now.
    if student.teacher_id.present? && student.teacher_id != user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

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

    render json: { sections: sections }, status: :ok
  end

  # GET /teachers
  # GET /teachers.json
  def index
    @teachers = Teacher.all
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
  end

  # POST /teachers
  # POST /teachers.json
  def create
    @teacher = Teacher.new(teacher_params)

    if @teacher.save
      render :show, status: :created, location: @teacher
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /teachers/1
  # PATCH/PUT /teachers/1.json
  def update
    if @teacher.update(teacher_params)
      render :show, status: :ok, location: @teacher
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  # DELETE /teachers/1
  # DELETE /teachers/1.json
  def destroy
    @teacher.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teacher
      @teacher = Teacher.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def teacher_params
      params.expect(teacher: [ :username, :email ])
    end
end
