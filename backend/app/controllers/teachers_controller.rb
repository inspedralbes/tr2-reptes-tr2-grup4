class TeachersController < ApplicationController
  # before_action :set_teacher, only: %i[ show update destroy ]

  # GET /teacher/students
  def students
    user = User.find_by(id: session[:user_id])
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    # TEMPORARY (until you wire real relation):
    render json: User.all.as_json(only: [:id, :username, :email]), status: :ok
  end

  # GET /teacher/students/:id/document
  def student_document
    user = User.find_by(id: session[:user_id])
    return render json: { error: "Unauthorized" }, status: :unauthorized unless user

    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # If you haven't wired teacher_id yet, comment this out for now.
    if student.teacher_id.present? && student.teacher_id != user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    pi = Pi.find_by(user_id: student.id)

    sections =
      if pi
        [
          { id: "description", title: "Description", content: pi.description, field: "description" },
          { id: "observations", title: "Observations", content: pi.observations, field: "observations" },
          { id: "medrec", title: "Medical Recommendations", content: pi.medrec, field: "medrec" },
          { id: "activities", title: "Activities", content: pi.activities, field: "activities" },
          { id: "interacttutorial", title: "Tutor Interaction", content: pi.interacttutorial, field: "interacttutorial" },
        ]
      else
        []
      end

    render json: { sections: sections }, status: :ok
  end

  # GET /teacher/students/:id/summary
  def student_summary
    student = User.find(params[:id])

    sections = student.pi&.sections || []
    text = sections_to_text(sections)

    if text.blank?
      return render json: { summary: "", error: "No document found." }, status: :unprocessable_entity
    end

    # TEMP STUB (AI later)
    render json: {
      summary: "Summary for student ##{student.id}. (Stub — replace with Ollama call)"
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Student not found" }, status: :not_found
  end

  # --- Scaffolded teacher CRUD (keep if you use it) ---

  def index
    @teachers = Teacher.all
  end

  def show
  end

  def create
    @teacher = Teacher.new(teacher_params)

    if @teacher.save
      render :show, status: :created, location: @teacher
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  def update
    if @teacher.update(teacher_params)
      render :show, status: :ok, location: @teacher
    else
      render json: @teacher.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy!
  end

  private

  def sections_to_text(sections)
    sections.map do |s|
      title = s["title"] || s[:title]
      content = s["content"] || s[:content]
      next if title.blank? && content.blank?
      "#{title}\n#{content}".strip
    end.compact.join("\n\n")
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_teacher
    @teacher = Teacher.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def teacher_params
    params.expect(teacher: [:username, :email])
  end
end
