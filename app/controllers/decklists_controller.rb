class DecklistsController < ApplicationController
    respond_to :html, :xml, :json

    def index
        @decklists = Decklist.all
    end

    def show
        @decklist = Decklist.find(params[:id])
        @ruler_deck = @decklist.decks.find_by(name: "Ruler")
        @decks = @decklist.decks.where.not(name: "Ruler").order(:name)
    end

    def new
        if current_user
            @decklist = Decklist.new
            @cards = Card.last(20)
        else
            flash[:warning] = "You must be logged in to create a decklist."
            redirect_to new_user_sessions_path
        end
    end

    def create
        @decklist = current_user.decklists.new(decklist_params)
        
        if @decklist.save
            flash[:success] = "Your decklist has been successfully created!"
            respond_to do |format|
                format.json { render json: @decklist }
            end
        else
            puts @decklist.errors.full_messages.join(", ")
            flash[:error] = @decklist.errors.full_messages.join(", ")
            respond_to do |format|
                format.json { render json: "Test" }
            end
        end
    end

    private
    def decklist_params
        name = params["decklist"]["name"]
        description = params["decklist"]["description"]
        decks = []
        
        params["decklist"]["decks"].each do |k, v|
            cards = []
            
            if v["cards"] != nil
                v["cards"].each do |id, card|
                    card["num"].to_i.times do 
                        cards << Card.find_by(name: card["name"])
                    end
                end
            end

            decks << Deck.new({name: v["name"], cards: cards })
        end

        {name: name, description: description, decks: decks}
    end
end
