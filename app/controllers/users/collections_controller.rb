class Users::CollectionsController < ApplicationController
    before_action :authenticate_user!

    def index
        @collections = current_user.collections
    end

    def show
        respond_to do |format|
            format.html do
                @collection = current_user.collections.find(params[:id])
                @cards = @collection.cards

                if params[:remaining_cards]
                    @remaining_cards = params[:remaining_cards]
                end
            end

            format.json { render json: CollectionCardsDatatable.new(view_context) }
        end
    end

    def new
        @collection = current_user.collections.new
    end

    def create
        @collection = current_user.collections.new(collection_params)
        
        if @collection.save
            remaining_cards = @collection.load_cards_from_form(params[:cards])
            flash[:success] = "Your collection has been successfully created!"
            redirect_to user_collection_path(current_user, @collection, remaining_cards: remaining_cards)
        else
            flash[:error] = @collection.errors.full_messages.join(", ")
            redirect_to new_user_collection_path(current_user)
        end
    end

    def edit
        @collection = current_user.collections.find(params[:id])  
    end

    def update
        @collection = current_user.collections.find(params[:id])
        
        if params[:cards]
            remaining_cards = @collection.load_cards_from_form(params[:cards])
        else
            @collection.update(collection_params)
        end

        redirect_to user_collection_path(current_user, @collection, remaining_cards: remaining_cards)
    end

    def destroy
        @collection = Collection.find(params[:id])
        @collection.delete

        flash[:success] = "Your collection has been successfully deleted!"
        redirect_to user_collections_path(current_user)
    end
    
    private

    def collection_params
        params.require(:collection).permit(:name)
    end
end