require 'pdf/reader'

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
      pages = extract_text_from_pdf(uploaded_file)

      text = clean_text(pages)
      text = truncate_text(text)

      summary = OllamaService.summarize(text)

      render json: {
        filename: uploaded_file.original_filename,
        summary: summary
      }, status: :ok
    rescue => e
      render json: { error: "Failed to process PDF: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def extract_text_from_pdf(uploaded_file)
    reader = PDF::Reader.new(uploaded_file.tempfile)

    reader.pages.map(&:text)
      .map { |t| t.gsub(/\s+/, ' ').strip }
      .reject(&:empty?)
  end

  def clean_text(pages)
    pages.join("\n")
         .gsub(/\s+/, ' ')
         .strip
  end

  def truncate_text(text, max_chars = 3000)
    text[0...max_chars]
  end
end
