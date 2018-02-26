class CardsController < ApplicationController
    def index
        respond_to do |format|
            format.html
            format.json { render json: CardsDatatable.new(view_context) }
        end
    end

    def show
        session[:return_to] ||= request.url

        @card = Card.find(params[:id])
        @tags = @card.tag_list
        @comments = @card.comments
        @comment = Comment.new
    end

    def edit
        @card = Card.find(params[:id])
    end

    def update
        @card = Card.find(params[:id])

        if @card.update(card_params)
            flash[:success] = "The card has been updated!"
        else
            flash[:error] = @card.errors.full_messages.join(", ")
        end

        redirect_to card_path(@card)
    end

    def card_params
        params.require(:card).permit(:tag_list)
    end
end