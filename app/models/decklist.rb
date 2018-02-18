class Decklist < ApplicationRecord
    belongs_to :user
    has_many :decks
    has_many :comments, as: :commentable

    validates :name, presence: true
    validates :name, uniqueness: true
    validates :description, presence: true

    def cards_needed_to_build(collections)
        decklist_cards_gbc = group_by_count(cards)    
        matching_collection_cards_gbc = group_collections_by_count(collections, decklist_cards_gbc)

        remaining = {}

        decklist_cards_gbc.each do |card_name, amount_and_id|
            if matching_collection_cards_gbc[card_name]
                collection_amount = matching_collection_cards_gbc[card_name]
                remaining_amount = amount_and_id[0] - collection_amount

                if remaining_amount > 0
                    remaining[card_name] = remaining_amount
                end
            else
                remaining[card_name] = amount_and_id[0]
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
                grouped_cards[card.name] = [0,[]]
            end

            grouped_cards[card.name][0] += 1
            grouped_cards[card.name][1] << card.id
        end

        grouped_cards
    end

    def group_collections_by_count(collections, card_set)
        grouped_cards = {}

        cards_collections = collections.inject([]) { |sum, n| sum + n.cards_collections }
        matching_cards = collections.inject([]) {|sum, collection| sum + collection.cards.where(name: card_set.keys) }
        matching_by_name = matching_cards.group_by {|card| card.name }
        name_and_ids = {}
        
        matching_by_name.each do |name, cards| 
            if name_and_ids[name] == nil
                name_and_ids[name] = []
            end

            cards.each do |card|
                name_and_ids[name] << card.id
            end
            
        end

        matching_cards_collections = cards_collections.select do |cards_collection| 
            name_and_ids.values.flatten.include?(cards_collection.card_id)
        end

        matching_cards_collections.each do |cards_collection|
            name_and_ids.each do |name, ids|
                if ids.include?(cards_collection.card_id)
                    if grouped_cards[name] == nil
                        grouped_cards[name] = 0
                    end

                    grouped_cards[name] += cards_collection.amount
                end
            end
        end

        grouped_cards
    end
end
