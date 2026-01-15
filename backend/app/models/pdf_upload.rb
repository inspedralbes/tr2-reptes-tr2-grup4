class PdfUpload < ApplicationRecord
  belongs_to :user

  enum status: {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  validates :user, presence: true
  validates :filename, presence: true
end
