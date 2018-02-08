class Api::V1::DecklistsController < ApiBaseController
    def index
        respond_with Decklist.all, status: :test
    end

    def show
        respond_with Decklist.find(params[:id])
    end

    def create
        @decklist = current_user.decklists.new(decklist_params)
        
        if @decklist.save
            respond_with @decklist
        else
            puts @decklist.errors.full_messages.join(", ")
            respond_with @decklist.errors.full_messages.join(", ")
        end
    end

    private

    def decklist_params
        name = params["decklist"]["name"]
        description = params["decklist"]["description"]
        decks = []
        
        params["decklist"]["decks"].each do |k, v|
            cards = []
            
            v["cards"].each do |id, card|
                card["num"].to_i.times do 
                    cards << Card.find_by(name: card["name"])
                end
            end

            decks << Deck.new({name: v["name"], cards: cards })
        end

        {name: name, description: description, decks: decks}
    end
end