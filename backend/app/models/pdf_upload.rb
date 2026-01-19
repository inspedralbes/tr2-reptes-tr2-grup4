class PdfUpload < ApplicationRecord
  belongs_to :user

  STATUSES = {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }.freeze

  validates :user, presence: true
  validates :filename, presence: true
end
