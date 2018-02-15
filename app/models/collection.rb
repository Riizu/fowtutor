class Collection < ApplicationRecord
  validates :name, presence: true

  belongs_to :user

  has_many :cards_collections, dependent: :delete_all
  has_many :cards, through: :cards_collections

  def load_cards_from_form(form_data)
    card_data = generate_card_data(form_data)
    added_cards = get_cards(card_data)
    
    card_collections = attach_new_cards(added_cards[:new])
    CardsCollection.import(card_collections, recursive: true)
    
    update_existing_cards(added_cards[:existing])

    added_cards[:remaining]
  end

  def update_existing_cards(existing_cards)
    existing_cards.each do |card, amount|
        cards_collection = cards_collections.find_by(card: card)
        existing_amount = cards_collection.amount
        new_amount = existing_amount + amount
        cards_collection.update(amount: new_amount)
    end
  end

  def get_cards(card_data)
    names = card_data.keys
    new_cards = Card.by_distinct_names(names)
    existing_card_names = cards.pluck(:name)
    card_names_found = new_cards.pluck(:name)
    remaining_names_downcased = names.map(&:downcase) - card_names_found.map(&:downcase)

    new_by_amount = {}
    existing_by_amount = {}

    new_cards.each do |card|
        if card_data[card.name.downcase] != nil
            if !existing_card_names.include?(card.name)
                new_by_amount[card] = card_data[card.name.downcase]
            else
                existing_by_amount[card] = card_data[card.name.downcase]
            end
        end
    end

    {new: new_by_amount, existing: existing_by_amount, remaining: remaining_names_downcased}
  end

  def attach_new_cards(new_cards)
    new_cards.map do |card, amount|
      cards_collections.new(collection_id: id, card_id: card.id, amount: amount)
    end
  end

  def generate_card_data(form_data)
    card_data = {}
      card_strings = form_data.strip.split(/\r\n/).reject { |c| c.empty? || c == "\t" || c == " \t" }
      
      card_strings.each do |entry|
          raw_amount = entry.split(" ")[0].gsub("x", "")
          raw_name = entry.split(" ", 2)[1]

          if raw_amount != nil && raw_name != nil
              amount = raw_amount.to_i
              name = raw_name.strip.downcase

              if card_data[name] == nil
                  card_data[name] = 0
              end

              card_data[name] += amount
          else
              puts "nil" + entry
          end
      end

      card_data
  end
end
