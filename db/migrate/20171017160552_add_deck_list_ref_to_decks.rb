class AddDeckListRefToDecks < ActiveRecord::Migration[5.1]
  def change
    add_reference :decks, :decklist, foreign_key: true
  end
end
