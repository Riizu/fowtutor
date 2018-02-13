class Cards::CommentsController < CommentsController
    before_action :set_commentable

    private 
        def set_commentable
            @commentable = Card.find(params[:card_id])
        end
end