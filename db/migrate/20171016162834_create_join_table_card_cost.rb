class CreateJoinTableCardCost < ActiveRecord::Migration[5.1]
  def change
    create_join_table :cards, :costs do |t|
      # t.index [:card_id, :cost_id]
      # t.index [:cost_id, :card_id]
    end
  end
end
