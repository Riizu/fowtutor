class Decklist < ApplicationRecord
    acts_as_taggable

    belongs_to :user
    has_many :decks
    has_many :comments, as: :commentable
    has_many :hearts, dependent: :destroy
    has_many :user_likes, through: :hearts, source: :user
    has_many :favorites, as: :favorited

    validates :name, presence: true
    validates :name, uniqueness: true
    validates :description, presence: true

    def ruler
        ruler = cards.find { |card| card.card_type.downcase == "ruler" }
    end

    def j_ruler
        j_ruler = cards.find { |card| card.card_type.downcase == "j-ruler" }
    end

    def cards_needed_to_build(collections)
        decklist_cards_gbc = group_by_count(cards)    
        matching_collection_cards_gbc = group_collections_by_count(collections, decklist_cards_gbc)

        remaining = {}

        decklist_cards_gbc.each do |card_name, amount_and_id|
            if matching_collection_cards_gbc[card_name] != nil
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
            card = cards.find {|card| card.name.downcase == card_name }
            final_result[card] = amount
        end

        final_result
    end

    def cards
        decks.inject([]) { |sum, n| sum + n.cards }
    end

    def cards_by_deck
        cards = {}
        cards[:ruler] = group_by_count_and_card(decks.find_by("lower(name) like ?", "%ruler%").cards, false)
        cards[:main] = group_by_count_and_card(decks.find_by("lower(name) like ?", "%main%").cards, false)
        cards[:stone] = group_by_count_and_card(decks.find_by("lower(name) like ?", "%stone%").cards, false)
        cards[:side] = group_by_count_and_card(decks.find_by("lower(name) like ?", "%side%").cards, false)
        cards
    end

    def group_by_count_and_card(card_set, downcase = true)
        grouped_cards = {}

        card_set.each do |card|
            if downcase
                name = card.name.downcase
            else
                name = card.name
            end

            if grouped_cards[name] == nil
                grouped_cards[name] = [0, nil]
            end

            grouped_cards[name][0] += 1
            grouped_cards[name][1] = card
        end

        grouped_cards
    end

    def group_by_count(card_set, downcase = true)
        grouped_cards = {}

        card_set.each do |card|
            if downcase
                name = card.name.downcase
            else
                name = card.name
            end

            if grouped_cards[name] == nil
                grouped_cards[name] = [0,[]]
            end

            grouped_cards[name][0] += 1
            grouped_cards[name][1] << card.id
        end

        grouped_cards
    end

    def group_collections_by_count(collections, card_set)
        grouped_cards = {}

        cards_collections = collections.inject([]) { |sum, n| sum + n.cards_collections }
        
        matching_cards = collections.inject([]) do |sum, collection| 
            sum + collection.cards.where("lower(name) in (?)", card_set.keys.map(&:downcase)) 
        end

        matching_by_name = matching_cards.group_by {|card| card.name }
        name_and_ids = {}
        
        matching_by_name.each do |name, cards| 
            downcased_name = name.downcase
            if name_and_ids[downcased_name] == nil
                name_and_ids[downcased_name] = []
            end

            cards.each do |card|
                name_and_ids[downcased_name] << card.id
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

    def self.sort_by(sort_type, user=nil, tag_name=nil)
        case sort_type
        when "recent"
            order(created_at: :desc)
        when "popular"
            popular
        when "tag"
            tagged_with(tag_name)
        when "most_liked"
            left_joins(:hearts).group(:id).order('COUNT(hearts.id) DESC')
        when "most_favorited"
            left_joins(:favorites).group(:id).order('COUNT(favorites.id) DESC')
        when "favorites"
            joins(:favorites).where(favorites: { user_id: 1 })
        when "owned"
            where(user: user)
        else
            popular
        end
    end

    def self.popular
        points = '(COUNT(hearts.*) + (COUNT(favorites.*) * 2) + (COUNT(comments.*) * 0.5))'
        popularity = "(((" + points + ") / POW(((EXTRACT(EPOCH FROM (now()-decklists.created_at)) / 3600)::integer + 2), 1.5))) AS popularity"

        Decklist.select('decklists.*', popularity)
        .left_outer_joins(:hearts).left_outer_joins(:favorites)
        .left_outer_joins(:comments)
        .group("decklists.id")
        .order('popularity DESC')
    end
end
