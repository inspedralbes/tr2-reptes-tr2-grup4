class PdfUploadsController < ApplicationController
  def show
    pdf_upload = PdfUpload.find(params[:id])

    render json: {
      id: pdf_upload.id,
      status: pdf_upload.status,
      summary: pdf_upload.summary,
      error: pdf_upload.error_message
    }
  end
end
