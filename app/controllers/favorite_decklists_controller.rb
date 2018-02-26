class FavoriteDecklistsController < ApplicationController
    before_action :set_decklist
    
    def create
      if Favorite.create(favorited: @decklist, user: current_user)
        redirect_back fallback_location: decklists_path, notice: 'decklist has been favorited'
      else
        redirect_back fallback_location: decklists_path, alert: 'Something went wrong...*sad panda*'
      end
    end
    
    def destroy
      Favorite.where(favorited_id: @decklist.id, user_id: current_user.id).first.destroy
      redirect_back fallback_location: decklists_path, notice: 'Decklist is no longer in favorites'
    end
    
    private
    
    def set_decklist
      @decklist = Decklist.find(params[:decklist_id] || params[:id])
    end
  end
  