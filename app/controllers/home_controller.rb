class HomeController < ApplicationController
  def index
    @decklists = Decklist.popular.limit(6)
  end
end
