class UploadFilesController < ApplicationController
  def create
    uploaded_file = params[:document]

    unless uploaded_file
      render json: { error: "No file received" }, status: :bad_request
      return
    end

    render json: {
      received: true,
      filename: uploaded_file.original_filename,
      content_type: uploaded_file.content_type,
      size: uploaded_file.size
    }, status: :ok
  end
end
