class HomeController < ApplicationController
  def index
    @five_most_recent_decks = Decklist.last(5)
    @five_most_viewed_decks = Decklist.last(5)
    @five_top_decks = Decklist.last(5)
  end
end
