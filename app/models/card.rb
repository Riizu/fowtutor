class Card < ApplicationRecord
    acts_as_taggable

    has_many :cards_costs
    has_many :costs, through: :cards_costs
    has_many :cards_decks
    has_many :decks, through: :cards_decks
    has_many :comments, as: :commentable
    has_many :cards_collections
    has_many :collections, through: :cards_collections


    validates :name, :code, :card_attribute,
              :card_type, presence: true
    validates :code, uniqueness: true

    scope :by_distinct_names, ->(names) {
        name_lower = arel_attribute(:name).lower
        where(name_lower.in(names.map(&:downcase))).tap do |relation|
        relation.arel.distinct_on(name_lower)
        end
    }

    def image_exists?(path)
        Faraday.head(path).status == 200
    end

    def image_path
        "https://s3.us-west-2.amazonaws.com/fowtutor/cards/" + code.gsub("/","-").gsub(" ", "%20") + ".jpg"
    end

    def thumbnail_path
        "https://s3.us-west-2.amazonaws.com/fowtutor/thumbnails/thumbnail-" + code.gsub("/","-").gsub(" ", "%20") + ".jpg"
    end


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

    def self.search(search_term)
        cards = where('lower(name) LIKE ?', "%" + search_term.downcase + "%")
        cards = cards.or(where('lower(text) LIKE ?', "%" + search_term.downcase + "%"))
        cards = cards.or(where('lower(card_type) LIKE ?', "%" + search_term.downcase + "%"))
        cards = cards.or(where('lower(subtype) LIKE ?', "%" + search_term.downcase + "%"))
        cards = cards.or(where('lower(card_attribute) LIKE ?', "%" + search_term.downcase + "%"))
    end
end
