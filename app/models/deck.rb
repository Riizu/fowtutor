class Deck < ApplicationRecord
    belongs_to :decklist
    has_many :cards_decks
    has_many :cards, through: :cards_decks

    def sort_by_card_type
        cards_by_card_type = {}
        
        cards.each do |card|
            if cards_by_card_type[card.card_type] == nil
                cards_by_card_type[card.card_type] = {}
            end

            if cards_by_card_type[card.card_type]["count"] == nil
                cards_by_card_type[card.card_type]["count"] = 0
            end

            if cards_by_card_type[card.card_type]["cards"] == nil
                cards_by_card_type[card.card_type]["cards"] = {}
            end

            if cards_by_card_type[card.card_type]["cards"][card] == nil
                cards_by_card_type[card.card_type]["cards"][card] = 0
            end

            cards_by_card_type[card.card_type]["cards"][card] += 1
            cards_by_card_type[card.card_type]["count"] += 1
        end

        cards_by_card_type
    end
end
