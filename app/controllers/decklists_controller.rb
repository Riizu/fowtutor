class DecklistsController < ApplicationController
    def index
        @decklists = Decklist.all
    end
end
