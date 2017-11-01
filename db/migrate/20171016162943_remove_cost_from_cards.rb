class RemoveCostFromCards < ActiveRecord::Migration[5.1]
  def change
    remove_column :cards, :cost, :string
  end
end
