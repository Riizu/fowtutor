class DecklistsController < ApplicationController
    before_action :authenticate_user!, only: [:edit, :update, :create, :new]

    respond_to :html, :xml, :json

    def index
        @decklists = Decklist.sort_by(params[:sort].to_s, current_user, params[:tag_name]).page(params[:page])
        @header = "Most Popular"
        
        if params[:sort]
            @header = params[:sort].capitalize
        end

        if params[:tag_name]
            @header = params[:tag_name].capitalize.pluralize
        end
    end

    def show
        @decklist = Decklist.find(params[:id])
        @ruler_deck = @decklist.decks.find_by(name: "Ruler")
        @decks = @decklist.decks.where.not(name: "Ruler").order(:name)
        if current_user
            @cards_needed = @decklist.cards_needed_to_build(current_user.collections)
        end
    end

    def edit
        @decklist = Decklist.find(params[:id])
        @decklist_cards = @decklist.cards_by_deck
    end

    def update
        @decklist = Decklist.find(params[:id])

        if @decklist.user == current_user
            if @decklist.update(decklist_params)
                flash[:success] = "Your decklist has been successfully updated!"

                respond_to do |format|
                    format.json { render json: @decklist }
                    format.html { redirect_to decklist_path(@decklist) }
                end
            else
                
                flash[:error] = @decklist.errors.full_messages.join(", ")

                respond_to do |format|
                    format.json { render json: "Test" }
                    format.html { redirect_to edit_decklist_path(@decklist) }
                end
            end
        else
            if @decklist.update(taglist_params)
                flash[:success] = "The decklist tags have been successfully updated!"

                respond_to do |format|
                    format.json { render json: @decklist }
                    format.html { redirect_to decklist_path(@decklist) }
                end
            else
                flash[:error] = @decklist.errors.full_messages.join(", ")
                
                respond_to do |format|
                    format.json { render json: "Test" }
                    format.html { redirect_to edit_decklist_path(@decklist) }
                end
            end
        end
    end

    def new
        @decklist = Decklist.new
        @cards = Card.last(20)        
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

    def destroy 
        @decklist = current_user.decklists.find(params[:id])
        
        if @decklist
            @decklist.decks.delete_all
            @decklist.delete
        end
        
        redirect_to decklists_path
    end

    private
    def taglist_params
        params.require(:decklist).permit(:tag_list)
    end
    
    def decklist_params
        name = params["decklist"]["name"]
        description = params["decklist"]["description"]
        tag_list = params["decklist"]["tag_list"]
        decks = []
        
        params["decklist"]["decks"].each do |k, v|
            cards = []
            
            if v["cards"] != nil
                v["cards"].each do |id, card|
                    card["num"].to_i.times do 
                        card = Card.find_by(code: card["code"])
                        if card == nil
                            return nil
                        else 
                            cards << card
                        end
                    end
                end
            end

            decks << Deck.new({name: v["name"], cards: cards })
        end

        results = {name: name, description: description, decks: decks, tag_list: tag_list}
    end
end
