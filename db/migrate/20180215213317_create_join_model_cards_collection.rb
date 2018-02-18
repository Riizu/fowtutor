class CreateJoinModelCardsCollection < ActiveRecord::Migration[5.1]
  def change
    create_table :cards_collections do |t|
      t.integer :collection_id
      t.integer :card_id
      t.integer :amount, default: 0
    end
  end
end
