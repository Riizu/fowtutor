# ========================================================================
# Seeds FoWTutor with cards, users, decklists, and decks.
# Capable of being used with a Scraping program that outputs an array of
# card data hashes. Otherwise generates a dummy
# Usage: 'rails db:seed' then follow prompts
# ========================================================================

require_relative 'generator'
require_relative 'multi_io'
require 'progress_bar'

class Seed
    def initialize
        now_stamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
        log_file = File.open("db/logs/seed_log_" + now_stamp + ".rb", "a")
        @logger = Logger.new(MultiIO.new(STDOUT, log_file))
        @logger.level = Logger::DEBUG
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S '

        @used_numbers = []
    end

    def start
        @logger.info("Welcome to the FoWTutor seed program. Please follow the prompts to get started.")
        
        fast_seed = yes_no_prompt("Would you like to use Fast Seed?")

        setup_card_data(fast_seed)
        create_users_with_decklists(fast_seed)
        
        @logger.info("Seeding program complete!")
    end

    def setup_card_data(fast_seed)
        if !fast_seed
            scraper = yes_no_prompt("Would you like to use a scraper or loading program for card data?")
        else
            @logger.info("Assuming card information already scraped and present in db/parsed_cards.txt!")
        end
        
        if scraper
            range = (0..4000)
            @logger.info("Scraping Cards in the range of #{range} - this could take awhile.")
            require_relative 'scraper/scraper'

            scraper = Scraper.new(range.to_a)
            scraper.start
        end

        load_cards()
        
        if Card.count > 1000
            @logger.info("1000+ cards found. Assuming Lapis Cluster is present. Proceeding with seed.")
        else
            @logger.info("No automated scraper used and an insufficient number of cards found (<1000). Please provide card data per documentation.")
            exit!
        end
    end

    def load_saved_cards_from_file(file_name)
        loaded_cards = []

        File.open(file_name, 'a+') do |f|
            data = f.read

            if data != ""
                loaded_cards = JSON.parse(data)    
            end
        end

        @logger.info("Loaded #{loaded_cards.count} Saved Cards into memory.")

        loaded_cards
    end

    def load_cards()
        cards = load_saved_cards_from_file("db/parsed_cards.txt")
        bar = ProgressBar.new(cards.length, :bar, :counter, :percentage, :eta)

        @logger.info("Now loading #{cards.count} Cards into DB.")
        
        cards.each do |card|
            new_card_costs = card["costs"].map do |new_cost|
                Cost.find_or_create_by(name: new_cost["name"])  do |cost|
                    cost.url = new_cost["url"]
                end
            end

            card["costs"] = new_card_costs

            new_card = Card.new(card)

            if new_card.valid?
                new_card.save!
            else
                @logger.info("Invalid card present. Logging card data.")
                @logger.info(new_card.errors.full_messages.join(", "))
                @logger.info(new_card)
            end

            bar.increment!
        end
    end
    
    def create_users_with_decklists(fast_seed)
        num_users = random_num_users(fast_seed)
        
        while num_users > 0
            num_decklists = random_num_decklists(fast_seed)
            
            if num_decklists > 0
                generator = build_generator(fast_seed)
            
                while num_decklists > 0
                    create_decklist(generator, fast_seed)
        
                    num_decklists -= 1

                    if num_decklists > 0
                        update_generator(generator, fast_seed)
                    end
                end

                generator.save
            end
            
    
            num_users -= 1
        end
    end
    
    def build_generator(fast_seed)
        if fast_seed
            email = random_email
            password = random_password
            username = random_username(email)
            sets = random_sets
            attributes = random_attributes
            deck_name = random_deck_name(attributes)
        else
            email = string_prompt("Enter an email for this user")
            password = string_prompt("Enter a password for this user")
            username = string_prompt("Enter an username for this user")
            sets = array_prompt("Please enter the sets you would like the first decklist to use")
            attributes = array_prompt("Please enter the attributes you would like the first decklist to use")
            deck_name = string_prompt("Please enter the name of the first decklist")
        end
          
        Generator.new(@logger, email, password, username, sets, attributes, deck_name)
    end

    def random_num_users(fast_seed)
        if fast_seed
            num_users = rand(20...100)
            @logger.info("Fast Seed: Generating #{num_users} users!")
        else
            num_users = integer_prompt("Enter the number of users you would like to create: ")
        end
    
        num_users
    end
    
    def random_num_decklists(fast_seed)
        if fast_seed
            num_decklists = rand(3...5)
            @logger.info("Fast Seed: Generating #{num_decklists} decklists")
        else
            num_decklists = integer_prompt("Enter the number of decklists you would like to create for this user")
        end
    
        num_decklists
    end
    
    def create_decklist(generator, fast_seed)
        generator.generate_decklist
    end

    def update_generator(generator, fast_seed)
        if fast_seed
            generator.sets = random_sets
            generator.attributes = random_attributes
            generator.deck_name = random_deck_name(generator.attributes)
        else 
            change_values = yes_no_prompt("Would you like to change the values for the next deck?")
            
            if change_values
                generator.sets = array_prompt("Please enter the sets you would like the next deck to use")
                generator.attributes = array_promopt("Please enter the attributes you would like the next deck to use")
            end
            
            generator.deck_name = string_prompt("Please enter the name of the next deck")
        end
    end
     
    def random_email
        random_num = rand(1...5000)
        existing_emails = User.pluck(:email)
        email = "test#{random_num}@fowtutor.com"

        while existing_emails.include?(email)
            random_num = rand(1...5000)
            email = "test#{random_num}@fowtutor.com"
        end

        @used_numbers << random_num

        email
    end

    def random_password
        "password"
    end

    def random_username(email)
        email.split("@")[0]
    end
    
    def random_sets
        ["SDL", "CFC", "LEL", "VIN003", "RDE", "ENW"]
    end
    
    def random_attributes
        possible_attributes = ["Light", "Wind", "Darkness", "Fire", "Water"]
        attributes = []
        num_attributes = rand(1...2)
        
        num_attributes.times do |i|
            attribute = possible_attributes.sample
            possible_attributes.delete(attribute)
            attributes << attribute
        end
    
        attributes
    end
    
    def random_deck_name(attributes)
        random_num = rand(1...5000)
        existing_names = Decklist.pluck(:name)
        name = attributes.join(" ") + " Deck ##{random_num}" 
        
        
        while existing_names.include?(name)
            random_num = rand(1...5000)
            name = attributes.join(" ") + " Deck ##{random_num}" 
        end

        name
    end
    
    def yes_no_prompt(prompt_text)
        print "\n#{prompt_text} (y/n): "
        value = STDIN.gets.chomp
        
        if value == 'y'
            true
        else
            false
        end
    end
    
    def integer_prompt(prompt_text)
        print "\n#{prompt_text}: "
        STDIN.gets.chomp.to_i
    end
    
    def string_prompt(prompt_text)
        print "\n#{prompt_text}: "
        STDIN.gets.chomp
    end
    
    def array_prompt(prompt_text)
        print "\n#{prompt_text}, seperated by commas: "
        
        values = STDIN.gets.chomp
        if values.include?(",")
            values.split(',')
        else
            [values]
        end
    end
    
end

seeder = Seed.new
seeder.start
