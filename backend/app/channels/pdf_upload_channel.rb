# PdfUploadChannel
#
# This channel handles real-time WebSocket connections for PDF upload updates.
#
# FLOW:
# 1. Frontend uploads a PDF via HTTP POST /upload
# 2. Backend creates a PdfUpload record and enqueues SummarizePdfJob
# 3. Frontend subscribes to this channel with the upload ID
# 4. Background job runs and broadcasts updates to this channel
# 5. Frontend receives updates instantly via WebSocket
#
# CHANNEL NAME:
#   pdf_upload_{id}  (e.g., pdf_upload_123)
#
# BROADCAST MESSAGES:
#   { status: "processing", message: "..." }
#   { status: "completed", summary: "..." }
#   { status: "failed", error: "..." }
#
# USAGE:
#   Backend:  PdfUploadChannel.broadcast_to(pdf_upload, { status: "completed", summary: "..." })
#   Frontend: cable.subscribe('PdfUploadChannel', { id: 123 }, callback)
#
class PdfUploadChannel < ApplicationCable::Channel
  # Called when a client subscribes to this channel
  #
  # The frontend sends:
  #   {"command":"subscribe","identifier":"{\"channel\":\"PdfUploadChannel\",\"id\":123}"}
  #
  # We respond by streaming from "pdf_upload_123"
  # Any broadcast to this channel name will be sent to the subscriber
  #
  def subscribed
    # Extract the PDF upload ID from the subscription params
    # The params come from the identifier JSON sent by the frontend
    pdf_upload_id = params[:id]

    if pdf_upload_id
      # Stream from a channel named "pdf_upload_{id}"
      # Example: If id is 123, we stream from "pdf_upload_123"
      stream_from "pdf_upload_#{pdf_upload_id}"
      logger.info "[PdfUploadChannel] Client subscribed to pdf_upload_#{pdf_upload_id}"
    else
      # Reject the subscription if no ID provided
      logger.warn "[PdfUploadChannel] Subscription rejected - no ID provided"
      reject
    end
  end

  # Called when a client unsubscribes from this channel
  #
  # This happens when:
  # - Client explicitly unsubscribes
  # - Client closes the WebSocket connection
  # - Server calls unsubscribe
  #
  def unsubscribed
    # Rails automatically stops streaming when unsubscribed
    # Override here if you need additional cleanup
    logger.info "[PdfUploadChannel] Client unsubscribed"
  end
end
