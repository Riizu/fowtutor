class CardsController < ApplicationController
    def index
        @cards = Card.all
    end

    def show
        session[:return_to] ||= request.url

        @card = Card.find(params[:id])
        @comments = @card.comments
        @comment = Comment.new
    end
end