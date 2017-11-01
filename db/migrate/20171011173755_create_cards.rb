class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.string :code
      t.string :card_attribute
      t.string :rarity
      t.string :cost
      t.string :card_type
      t.string :subtype
      t.string :illustrator
      t.string :attack
      t.string :defense
      t.string :text
      t.string :flavor

      t.timestamps
    end
  end
end
