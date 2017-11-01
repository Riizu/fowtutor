class CreateDecklists < ActiveRecord::Migration[5.1]
  def change
    create_table :decklists do |t|
      t.string :name

      t.timestamps
    end
  end
end
