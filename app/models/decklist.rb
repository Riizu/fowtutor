class Decklist < ApplicationRecord
    belongs_to :user
    has_many :decks
    has_many :comments, as: :commentable

    validates :name, presence: true
    validates :name, uniqueness: true
    validates :description, presence: true

    def cards_needed_to_build(collections)
        decklist_cards_gbc = group_by_count(cards)
        matching_collection_cards_gbc = group_collections_by_count(collections, cards)

        remaining = {}

        decklist_cards_gbc.each do |card_name, amount|
            collection_amount = matching_collection_cards_gbc[card_name]
            remaining_amount = amount - collection_amount

            if remaining_amount > 0
                remaining[card_name] = remaining_amount
            end
        end

        final_result = {}

        remaining.each do |card_name, amount|
            card = cards.find {|card| card.name == card_name }
            final_result[card] = amount
        end

        final_result
    end

    def cards
        decks.inject([]) { |sum, n| sum + n.cards }
    end

    def group_by_count(card_set)
        grouped_cards = {}

        card_set.each do |card|
            if grouped_cards[card.name] == nil
                grouped_cards[card.name] = 0
            end

            grouped_cards[card.name] += 1
        end

        grouped_cards
    end

    def group_collections_by_count(collections, card_set)
        grouped_cards = {}

        cards_collections = collections.inject([]) { |sum, n| sum + n.cards_collections }
        card_set.each do |card|
            matching_collections = cards_collections.select {|cards_collection| cards_collection.card.name == card.name}
            total_amount = matching_collections.inject(0) {|sum, n| sum + n.amount }

            if grouped_cards[card.name] == nil
                grouped_cards[card.name] = 0
            end

            grouped_cards[card.name] += total_amount
        end

        grouped_cards
    end
end
