class UsersController < ApplicationController
    def show
        session[:return_to] ||= request.url

        @user = User.find(params[:id])
        @comment_count = Comment.where(user: @user).count
        @decklists = @user.decklists
        @decklist_count = @decklists.count
    end
end