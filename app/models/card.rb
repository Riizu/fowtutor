class Card < ApplicationRecord
    has_many :cards_costs
    has_many :costs, through: :cards_costs
    has_many :cards_decks
    has_many :decks, through: :cards_decks

    validates :name, :code, :card_attribute,
              :card_type, presence: true
    validates :code, uniqueness: true


    def self.find_sets(sets_array)
        first_set = sets_array.first
        sets = sets_array - [first_set]
        cards = where("code like ?", "#{first_set}%")
        sets.each do |set|
            cards = cards.or(where("code like ?", "#{set}%"))
        end
        cards
    end

    def self.find_types(types_array)
        first_type = types_array.first
        types = types_array - [first_type]
        cards = where(card_type: first_type)
        types_array.each do |card_type|
            cards = cards.or(where(card_type: card_type))
        end
        cards
    end

    def self.find_attributes(attributes_array)
        first_attribute = attributes_array.first
        attributes = attributes_array - [first_attribute]
        cards = where(card_attribute: first_attribute)
        attributes_array.each do |card_attribute|
            cards = cards.or(where(card_attribute: card_attribute))
        end
        cards
    end
end
