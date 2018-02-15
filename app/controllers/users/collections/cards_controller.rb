class Users::Collections::CardsController < ApplicationController    
    before_action :authenticate_user!

    def update
        puts params[:id]
        @collection = current_user.collections.find(params[:collection_id])
        
        if @collection
            card = @collection.cards.find(params[:id])
            cards_collection = @collection.cards_collections.find_by(collection: @collection, card: card)
            
            amount = cards_collection.amount + 1 
            cards_collection.update(amount: amount)
            
            redirect_to user_collection_path(current_user, @collection)
        end
    end
    
    def destroy
        @collection = current_user.collections.find(params[:collection_id])
        
        if @collection
            card = @collection.cards.find(params[:id])
            cards_collection = @collection.cards_collections.find_by(collection: @collection, card: card)

            if cards_collection.amount > 1
                amount = cards_collection.amount - 1
                cards_collection.update(amount: amount)
            else
                @collection.cards.delete(card)
            end

            redirect_to user_collection_path(current_user, @collection)
        end
    end
end