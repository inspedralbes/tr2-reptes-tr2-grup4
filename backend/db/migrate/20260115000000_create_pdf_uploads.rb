class CreatePdfUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :pdf_uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.string :filename
      t.text :original_text
      t.text :summary
      t.string :status, default: "pending"
      t.text :error_message

      t.timestamps
    end
  end
end
