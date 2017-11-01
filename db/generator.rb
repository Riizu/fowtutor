class Generator
    attr_accessor :attributes, :sets, :deck_name

    def initialize(email, password, sets, attributes, deck_name)
        @sets = sets
        @attributes = attributes
        @deck_name = deck_name
        
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S '

        @user = generate_user(email, password)
    end

    def generate_user(email, password)
        @logger.info("Generating a user with the email #{email}.")
        User.new(email: email, password: password)
    end

    def generate_decklist
        @logger.info("Generating a decklist named '#{@deck_name}' for '#{@user.email}'.")
        decklist = Decklist.new(name: @deck_name, user: @user)
        
        ruler_deck = generate_ruler_deck(decklist)
        main_deck = generate_main_deck(decklist)
        stone_deck = generate_stone_deck(decklist)
        side_deck = generate_side_deck(decklist)

        decklist.decks << ruler_deck
        decklist.decks << main_deck
        decklist.decks << stone_deck
        decklist.decks << side_deck

        @user.decklists << decklist
    end

    def save
        @logger.info("Saving #{@user.email}'s data.")
        
        @user.save!
    end

    def generate_ruler_deck(decklist)
        ruler_deck = Deck.new(name: "Ruler", decklist: decklist)
        ruler_attribute = @attributes.join("/")

        ruler = Card.find_sets(@sets)
                    .where(card_attribute: ruler_attribute)
                    .where(card_type: "Ruler").first

        if ruler == nil
            @attributes = @attributes.reverse
            ruler_attribute = @attributes.join("/")
            ruler = Card.find_sets(@sets)
                    .where(card_attribute: ruler_attribute)
                    .where(card_type: "Ruler").first
        end

        j_ruler = Card.where(code: ruler.code + "J")
        
        ruler_deck.cards << ruler
        ruler_deck.cards << j_ruler

        ruler_deck
    end

    def generate_main_deck(decklist)
        main_deck = Deck.new(name: "Main Deck", decklist: decklist)
        card_types = ["Resonator", "Chant", "Addition"]
        
        @attributes.each do |attribute|
            cards = get_cards(40/@attributes.count, @sets, [attribute], card_types)
            main_deck.cards << cards
        end
    
        main_deck
    end
    
    def generate_stone_deck(decklist)
        stone_deck = Deck.new(name: "Stone Deck", decklist: decklist)
        
        @attributes.each do |attribute|
            name = attribute + " Magic Stone"
            stone_deck.cards << get_stones(10/@attributes.count, @sets, name)
        end
        
        stone_deck
    end
    
    def generate_side_deck(decklist)
        Deck.new(name: "Side Deck", decklist: decklist)
    end

    def get_cards(num_cards, sets, attributes, card_types)
        Card.find_attributes(attributes)
            .find_sets(sets)
            .find_types(card_types)
            .order("RANDOM()").limit(num_cards)
    end
    
    def get_stones(num_stones, sets, name)
        possible_stones = Card.find_sets(sets)
                            .where(name: name)
    
        num_stones.times.map do |i| 
            possible_stones.sample
        end
    end
end