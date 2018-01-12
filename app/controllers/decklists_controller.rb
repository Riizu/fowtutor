class DecklistsController < ApplicationController
    def index
        @decklists = Decklist.all
    end

    def show
        @decklist = Decklist.find(params[:id])
        @ruler_deck = @decklist.decks.find_by(name: "Ruler")
        @decks = @decklist.decks.where.not(name: "Ruler").order(:name)
    end
end
