class CreateTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :teachers do |t|
      t.string :username
      t.string :email

      t.timestamps
    end
  end
end
