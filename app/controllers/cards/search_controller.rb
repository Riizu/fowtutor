class Cards::SearchController < ApplicationController
    respond_to :html, :xml, :json
    
    def create
        @results = Card.search(params[:name])
        
        respond_to do |format|
            format.json { render json: @results }
        end
    end
end