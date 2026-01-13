class UploadFilesController < ApplicationController
  def create
    uploaded_file = params[:document]

    unless uploaded_file
      render json: { error: "No file received" }, status: :bad_request
      return
    end

    unless uploaded_file.content_type == "application/pdf"
      render json: { error: "Only PDF files allowed" }, status: :unsupported_media_type
      return
    end

    begin
      text = extract_text_from_pdf(uploaded_file)

      render json: {
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type,
        size: uploaded_file.size,
        text: text
      }, status: :ok
    rescue => e
      render json: { error: "Failed to read PDF: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def extract_text_from_pdf(uploaded_file)
    # Pass the path explicitly
    PDF::Reader.new(uploaded_file.tempfile.path).pages.map(&:text).join("\n")
  end
end
