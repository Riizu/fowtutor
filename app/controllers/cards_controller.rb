class CardsController < ApplicationController
    def index
        # byebug
        respond_to do |format|
            format.html
            format.json { render json: CardsDatatable.new(view_context) }
        end
    end

    def show
        session[:return_to] ||= request.url

        @card = Card.find(params[:id])
        @comments = @card.comments
        @comment = Comment.new
    end
end