class PdfUploadChannel < ApplicationCable::Channel
   def subscribed
     pdf_upload_id = params[:id]
     logger.info "[PdfUploadChannel] Subscription attempt with params: #{params.inspect}"

     if pdf_upload_id
       pdf_upload = PdfUpload.find(pdf_upload_id)
       # Create channel name
       channel_name = "#{pdf_upload.class.name.underscore}:#{pdf_upload.to_gid_param}"
       stream_from channel_name
       logger.info "[PdfUploadChannel] Client subscribed to #{channel_name}"
     else
       reject
     end
  end

  def unsubscribed
    logger.info "[PdfUploadChannel] Client unsubscribed"
  end
end
