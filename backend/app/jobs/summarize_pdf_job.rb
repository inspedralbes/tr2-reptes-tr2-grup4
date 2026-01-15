class SummarizePdfJob < ApplicationJob
  queue_as :default

  def perform(pdf_upload_id)
    pdf_upload = PdfUpload.find(pdf_upload_id)

    pdf_upload.update!(status: :processing)

    summary = OllamaService.summarize(pdf_upload.original_text)

    pdf_upload.update!(summary: summary, status: :completed)
  rescue => e
    pdf_upload.update!(status: :failed, error_message: e.message)
    raise
  end
end
