# =============================================================================
# SummarizePdfJob
# =============================================================================
# Background job that processes PDF uploads using Ollama.
#
# HOW IT WORKS:
# 1. Controller enqueues this job with a pdf_upload_id
# 2. Solid Queue worker picks up the job
# 3. Job processes the PDF text with Ollama
# 4. Job broadcasts real-time updates to WebSocket subscribers
#
# KEY METHODS:
# - perform(pdf_upload_id) - Main entry point called by Solid Queue
#
# WEB SOCKET BROADCASTING:
# - When status changes, we call PdfUploadChannel.broadcast_to(pdf_upload, data)
# - This sends the data to all clients subscribed to "pdf_upload_{id}"
# - Frontend receives these updates instantly via WebSocket
#
# =============================================================================

class SummarizePdfJob < ApplicationJob
  # Set the queue name for this job
  # Jobs with the same queue name are processed in order
  # Default queue is fine for most use cases
  queue_as :default

  # Main method called by Solid Queue worker
  #
  # @param [Integer] pdf_upload_id - The ID of the PdfUpload record to process
  #
  # HOW IT WORKS:
  # 1. Find the PdfUpload record in the database
  # 2. Mark status as "processing" and broadcast to WebSocket
  # 3. Call OllamaService to summarize the text
  # 4. Update record with summary and mark as "completed"
  # 5. Broadcast the final result to all subscribed clients
  #
  def perform(pdf_upload_id)
    logger.info "[SummarizePdfJob] Starting job for PDF upload #{pdf_upload_id}"

    # Find the PDF upload record in the database
    # This raises ActiveRecord::RecordNotFound if the record doesn't exist
    pdf_upload = PdfUpload.find(pdf_upload_id)
    logger.info "[SummarizePdfJob] Found PDF upload: #{pdf_upload.id}, text length: #{pdf_upload.original_text.length}"

    # Update status to "processing" so we know the job started
    # This helps track which jobs are currently running
    pdf_upload.update!(status: "processing")
    logger.info "[SummarizePdfJob] Updated status to processing"

    # BROADCAST: Tell all WebSocket subscribers that processing started
    # This sends a message to everyone subscribed to "pdf_upload_{id}"
    #
    # The broadcast_to method:
    # 1. Takes the model (pdf_upload) to determine the channel name
    # 2. Serializes the data hash to JSON
    # 3. Publishes to the pub/sub channel
    # 4. All subscribers to "pdf_upload_{pdf_upload.id}" receive this message
    logger.info "[SummarizePdfJob] Broadcasting processing status to pdf_upload_#{pdf_upload.id}"
    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        # Status tells the frontend what stage we're at
        status: "processing",
        # Optional: Add progress percentage or message
        message: "Starting to process PDF..."
      }
    )

    # Call Ollama to summarize the text
    # This is the actual work that takes time (seconds to minutes)
    #
    # OllamaService.summarize takes the extracted text and returns a summary
    # The text was stored in the PdfUpload record when the file was uploaded
    summary = OllamaService.summarize(pdf_upload.original_text)

    # Update the record with the result from Ollama
    # Store the summary and mark the job as completed
    pdf_upload.update!(summary: summary, status: "completed")

    # BROADCAST: Send the final result to all subscribers
    # The frontend will receive this and can display the summary to the user
    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        status: "completed",
        summary: summary,
        message: "PDF processing complete!"
      }
    )

  # Handle any errors that occur during processing
  rescue => e
    # Update the record to show the job failed
    # Store the error message so we can debug later
    pdf_upload.update!(status: "failed", error_message: e.message)

    # BROADCAST: Notify subscribers that the job failed
    # The frontend can show an error message to the user
    PdfUploadChannel.broadcast_to(
      pdf_upload,
      {
        status: "failed",
        error: e.message,
        message: "PDF processing failed"
      }
    )

    # Re-raise the error so Solid Queue knows the job failed
    # This allows Solid Queue to:
    # 1. Mark the job as failed
    # 2. Optionally retry the job if configured
    # 3. Log the error for debugging
    raise
  end
end
