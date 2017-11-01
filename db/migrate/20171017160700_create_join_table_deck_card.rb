class CreateJoinTableDeckCard < ActiveRecord::Migration[5.1]
  def change
    create_join_table :decks, :cards do |t|
      # t.index [:deck_id, :card_id]
      # t.index [:card_id, :deck_id]
    end
  end
end
