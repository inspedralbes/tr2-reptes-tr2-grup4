class CreatePis < ActiveRecord::Migration[8.1]
  def change
    create_table :pis do |t|
      t.text :description
      t.text :observations
      t.text :medrec
      t.text :activities
      t.text :interacttutorial

      t.timestamps
    end
  end
end
