class AddRoleAndTeacherIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string
    add_column :users, :teacher_id, :bigint
  end
end
