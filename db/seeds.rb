# ========================================================================
# Seeds FoWTutor with cards, users, decklists, and decks.
# Capable of being used with a Scraping program that outputs an array of
# card data hashes. Otherwise generates a dummy
# Usage: 'rails db:seed' then follow prompts
# ========================================================================

require_relative 'generator'

class Seed
    def initialize
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S '

        @used_numbers = []
    end

    def start
        puts "Welcome to the FoWTutor seed program. Please follow the prompts to get started."
        
        fast_seed = yes_no_prompt("Would you like to use Fast Seed?")

        setup_card_data(fast_seed)
        create_users_with_decklists(fast_seed)
        
        puts "Seeding program complete!"
    end

    def setup_card_data(fast_seed)
        if !fast_seed
            scraper = yes_no_prompt("Would you like to use a scraper for card data?")
        end
        
        if scraper || fast_seed
            range = (0..4000)
            @logger.info("Scraping Cards in the range of #{range} - this could take awhile.")
            require_relative 'scraper/scraper'

            scraper = Scraper.new(range.to_a)
            scraper.start
        end
    end
    
    def create_users_with_decklists(fast_seed)
        num_users = random_num_users(fast_seed)
        
        while num_users > 0
            generator = build_generator(fast_seed)
            num_decklists = random_num_decklists(fast_seed)
            
            while num_decklists > 0
                create_decklist(generator, fast_seed)
    
                num_decklists -= 1
            end

            generator.save
    
            num_users -= 1
        end
    end
    
    def build_generator(fast_seed)
        if fast_seed
            email = random_email
            password = random_password
            sets = random_sets
            attributes = random_attributes
            deck_name = random_deck_name(attributes)
        else
            email = string_prompt("Enter an email for this user")
            password = string_prompt("Enter a password for this user")
            sets = array_prompt("Please enter the sets you would like the first deck to use")
            attributes = array_prompt("Please enter the attributes you would like the first deck to use")
            deck_name = string_prompt("Please enter the name of the first deck")
        end
          
        Generator.new(email, password, sets, attributes, deck_name)
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
    
    def random_sets
        possible_sets = ["SDL", "CFC", "LEL", "VIN003", "RDE", "ENW"]
        # sets = []
    
        # num_sets = rand(1...6)
        # num_sets.times do |i|
        #     set = possible_sets.sample
        #     possible_sets.delete(set)
        #     sets << set
        # end
    
        possible_sets
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
