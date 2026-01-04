class CreatePis < ActiveRecord::Migration[8.1]
  def change
    create_table :pis do |t|
      t.string :name
      t.text :description
      t.text :observations
      t.text :certificates

      t.timestamps
    end
  end
end
