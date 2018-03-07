class HeartsController < ApplicationController
    respond_to :js

    def heart
        @user = current_user
        @decklist = Decklist.find(params[:decklist_id])
        @user.heart!(@decklist)
    end

    def unheart
        @user = current_user
        @heart = @user.hearts.find_by_decklist_id(params[:decklist_id])
        @decklist = Decklist.find(params[:decklist_id])
        @heart.destroy!
    end
end
