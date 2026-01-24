class TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_teacher!, except: []

  # GET /teacher/students
  def students
    # Only return students assigned to current teacher
    assigned_students = User.where(role: "student", teacher_id: @current_user.id)
    render json: assigned_students.as_json(only: [:id, :username, :email]), status: :ok
  end

  # GET /teacher/students/:id/document
  def student_document
    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # Check that the student is assigned to this teacher
    if student.teacher_id != @current_user.id
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

  def download_student_document
    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # Check that the student is assigned to this teacher
    if student.teacher_id != @current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    @pi = Pi.find_by(user_id: student.id)
    if @pi.blank?
      render json: { error: "This student has no PI yet." }, status: :not_found
      return
    end

    @pi.reload
    @pdf_user = student

    html = render_to_string(template: "pis_layout/pdf", layout: "layouts/pdf", formats: [:html])
    pdf = WickedPdf.new.pdf_from_string(html, wkhtmltopdf_options)

    send_data pdf,
              filename: "pi_student_#{student.id}_#{Date.today}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  # GET /teacher/students/:id/summary
  def student_summary
    student = User.find(params[:id])
    
    # Check that the student is assigned to this teacher
    if student.teacher_id != @current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    pi = Pi.find_by(user_id: student.id)
    return render json: { summary: "", error: "No document found." }, status: :unprocessable_entity unless pi

    input_text = OllamaTeacher.build_text_from_pi(
      description: pi.description,
      observations: pi.observations,
      medrec: pi.medrec,
      activities: pi.activities,
      interacttutorial: pi.interacttutorial
    )

    begin
      summary = OllamaTeacher.summarize(input_text, student_name: student.username)
      render json: { summary: summary }
    rescue => e
      render json: { error: e.message, summary: "" }, status: :unprocessable_entity
    end
  end

  # POST /teacher/students/:id/document
  def upload_student_document
    student = User.find_by(id: params[:id])
    return render json: { error: "Student not found" }, status: :not_found unless student

    # Check that the student is assigned to this teacher
    if student.teacher_id != @current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    uploaded_file = params[:document]

    unless uploaded_file
      return render json: { error: "No file received" }, status: :bad_request
    end

    unless uploaded_file.content_type == "application/pdf"
      return render json: { error: "Only PDF files allowed" }, status: :unsupported_media_type
    end

    text = extract_text_from_pdf(uploaded_file)

    pdf_upload = PdfUpload.create!(
      user: student,
      filename: uploaded_file.original_filename,
      original_text: text,
      status: "pending"
    )

    SummarizePdfJob.perform_later(pdf_upload.id)

    render json: { id: pdf_upload.id, status: "processing", message: "PDF is being processed" }, status: :accepted
  rescue => e
    render json: { error: "Failed to process PDF: #{e.message}" }, status: :unprocessable_entity
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

  def extract_text_from_pdf(uploaded_file)
    reader = PDF::Reader.new(uploaded_file.tempfile.path)
    reader.pages.map(&:text)
      .map { |t| t.gsub(/\s+/, " ").strip }
      .reject(&:empty?)
      .join("\n")
  end

  def wkhtmltopdf_options
    {
      "page-size": "A4",
      "margin-top": "0.75in",
      "margin-right": "0.75in",
      "margin-bottom": "0.75in",
      "margin-left": "0.75in"
    }
  end

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
