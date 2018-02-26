class DecklistsController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :create]

    respond_to :html, :xml, :json

    def index
        @decklists = Decklist.page(params[:page])
    end

    def show
        @decklist = Decklist.find(params[:id])
        @ruler_deck = @decklist.decks.find_by(name: "Ruler")
        @decks = @decklist.decks.where.not(name: "Ruler").order(:name)
        @cards_needed = @decklist.cards_needed_to_build(current_user.collections)
    end

    def edit
        @decklist = Decklist.find(params[:id])
        @ruler_cards = @decklist.group_by_count(@decklist.decks.find_by(name: "Ruler").cards, false)
        @main_cards = @decklist.group_by_count(@decklist.decks.find_by(name: "Main Deck").cards, false)
        @stone_cards = @decklist.group_by_count(@decklist.decks.find_by(name: "Stone Deck").cards, false)
        @side_cards = @decklist.group_by_count(@decklist.decks.find_by(name: "Side Deck").cards, false)
    end

    def update
        @decklist = Decklist.find(params[:id])

        if @decklist.user.id == current_user.id
            if @decklist.update(decklist_params)
                flash[:success] = "Your decklist has been successfully updated!"
                respond_to do |format|
                    format.json { render json: @decklist }
                end
            else
                flash[:error] = @decklist.errors.full_messages.join(", ")
                respond_to do |format|
                    format.json { render json: "Test" }
                end
            end
        else
            if @decklist.update(tag_list: params[:decklist][:tag_list])
                flash[:success] = "The decklist tags have been successfully updated!"
                redirect_to decklist_path(@decklist)     
            else
                flash[:error] = @decklist.errors.full_messages.join(", ")
                respond_to do |format|
                    format.json { render json: "Test" }
                end
            end
        end        
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

            # byebug

            decks << Deck.new({name: v["name"], cards: cards })
        end

        {name: name, description: description, decks: decks, tag_list: params[:tag_list]}
    end
end
