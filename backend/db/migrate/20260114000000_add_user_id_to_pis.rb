class AddUserIdToPis < ActiveRecord::Migration[7.2]
  def change
    add_reference :pis, :user, null: false, foreign_key: true
  end
end
