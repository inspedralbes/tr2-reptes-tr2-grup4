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

    # Fetch user's Pi data
    pi_data = pdf_upload.user.pi&.as_json(only: [ :description, :observations, :medrec, :activities, :interacttutorial ]) || {}

    # Start the summarize step with ollama
    result_json = OllamaService.summarize(pdf_upload.original_text, pi_data)

    begin
      parsed = JSON.parse(result_json)

      # Update Pi if exists, appending fields
      if pdf_upload.user.pi
        pi = pdf_upload.user.pi
        # Clean existing Pi fields to remove any nested hash strings from previous bad updates
        clean_pi_fields(pi)
        pi.update!(
          description: append_field(pi.description, parsed["description"]),
          observations: append_field(pi.observations, parsed["observations"]),
          medrec: append_field(pi.medrec, parsed["medrec"]),
          activities: append_field(pi.activities, parsed["activities"]),
          interacttutorial: append_field(pi.interacttutorial, parsed["interacttutorial"])
        )
      end

      pdf_upload.update!(summary: parsed["pdf_summary"], status: "completed")

      PdfUploadChannel.broadcast_to(
        pdf_upload,
        {
          status: "completed",
          summary: parsed["pdf_summary"],
          message: "PDF processing complete!"
        }
      )
    rescue JSON::ParserError => e
      raise "Failed to parse Ollama response: #{e.message}"
    end

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

  private

  def append_field(existing, new)
    return existing unless new.present? && new != "$end"
    # If new is a hash (e.g., {"existing": "...", "pdf_added": "..."}), extract the addition
    if new.is_a?(Hash)
      addition = new["pdf_added"] || new["new"] || ""
      return existing if addition.blank?
      new = addition
    end
    [ existing, new ].compact.join(" ")
  end

  def clean_pi_fields(pi)
    # Remove nested hash strings like {"existing" => "...", "pdf_added" => "..."} from each field
    hash_pattern = /\{\s*"[^"]*"\s*=>\s*[^}]*\}/
    pi.attributes.each do |attr, value|
      next unless value.is_a?(String)
      cleaned = value.gsub(hash_pattern, "").strip
      pi.assign_attributes(attr => cleaned) if cleaned != value
    end
end
end
