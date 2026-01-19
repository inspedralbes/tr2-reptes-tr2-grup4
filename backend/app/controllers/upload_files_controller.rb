require "pdf/reader"

class UploadFilesController < ApplicationController
  def create
    uploaded_file = params[:document]

    unless uploaded_file
      return render json: { error: "No file received" }, status: :bad_request
    end

    unless uploaded_file.content_type == "application/pdf"
      return render json: { error: "Only PDF files allowed" }, status: :unsupported_media_type
    end

    begin
      text = extract_text_from_pdf(uploaded_file)

      pdf_upload = PdfUpload.create!(
        user: current_user,
        filename: uploaded_file.original_filename,
        original_text: text,
        status: "pending"
      )

      SummarizePdfJob.perform_later(pdf_upload.id)

      render json: {
        id: pdf_upload.id,
        status: "processing",
        message: "PDF is being processed"
      }, status: :accepted
    rescue => e
      render json: { error: "Failed to process PDF: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def extract_text_from_pdf(uploaded_file)
    reader = PDF::Reader.new(uploaded_file.tempfile.path)

    reader.pages.map(&:text)
      .map { |t| t.gsub(/\s+/, " ").strip }
      .reject(&:empty?)
      .join("\n")
  end
end
