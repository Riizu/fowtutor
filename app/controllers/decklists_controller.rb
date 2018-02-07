class DecklistsController < ApplicationController
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
            redirect_to decklist_path(@decklist)
        else
            flash.now[:error] = @decklist.errors.full_messages.join(", ")
            redirect_to new_decklist_path
        end
    end

    private

    def decklist_params
        params.require(:decklist).permit(:name, :description)
    end
end
