class Decklists::CommentsController < CommentsController
    before_action :set_commentable

    private 
        def set_commentable
            @commentable = Decklist.find(params[:decklist_id])
        end
end