class AddDescriptionsToDecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :decklists, :description, :string
  end
end
