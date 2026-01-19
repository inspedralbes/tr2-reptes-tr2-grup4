class SummarizePdfJob < ApplicationJob
  queue_as :default

  # Base method of the job to do something
  def perform(pdf_upload_id)
    logger.info "[SummarizePdfJob] Starting job for PDF upload #{pdf_upload_id}"

    # Get the pdf with the extracted text
    pdf_upload = PdfUpload.find(pdf_upload_id)
    logger.info "[SummarizePdfJob] Found PDF upload: #{pdf_upload.id}, text length: #{pdf_upload.original_text.length}"

    # Once found update its status
    pdf_upload.update!(status: "processing")

    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        status: "processing",
        message: "Starting to process PDF..."
      }
    )

    # Start the summarize step with ollama
    summary = OllamaService.summarize(pdf_upload.original_text)

    pdf_upload.update!(summary: summary, status: "completed")

    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        status: "completed",
        summary: summary,
        message: "PDF processing complete!"
      }
    )

  rescue => e
    pdf_upload.update!(status: "failed", error_message: e.message)

    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        status: "failed",
        error: e.message,
        message: "PDF processing failed"
      }
    )
    raise
  end
end
