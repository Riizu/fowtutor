class AddUserRefToDecklist < ActiveRecord::Migration[5.1]
  def change
    add_reference :decklists, :user, foreign_key: true
  end
end
