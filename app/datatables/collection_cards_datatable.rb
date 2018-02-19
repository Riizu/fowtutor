class CollectionCardsDatatable < ApplicationDatatable
    delegate :user_collection_card_path, to: :@view

    private

    def data
        collection = Collection.find(params[:id])

        cards.map do |card|
            [].tap do |column|
                column << CardsCollection.find_by(collection: collection, card: card).amount.to_i
                column << card.code
                column << card.name
                column << card.card_attribute
                column << card.card_type
                column << card.subtype
                
                links = []
                links << link_to("Add", user_collection_card_path(params[:user_id], params[:id], card.id), method: :patch)
                links << link_to("Pull", user_collection_card_path(params[:user_id], params[:id], card.id), method: :delete)
                column << links.join(' | ')
                
            end
        end
    end

    def count
        Collection.find(params[:id]).cards_collections.pluck(:amount).reduce(:+)
    end

    def total_entries
        cards.total_count
    end

    def cards
        @cards ||= fetch_cards
    end

    def fetch_cards
        search_string = []
        columns.each do |term|
            search_string << "lower(#{term}) like :search"
        end

        cards = Collection.find(params[:id]).cards
        cards = cards.order("#{sort_column} #{sort_direction}")
        cards = cards.page(page).per(per_page)
        cards = cards.where(search_string.join(' or '), search: "%#{params[:search][:value].downcase}%")
    end

    def columns
        %w(code name card_attribute card_type subtype)
    end
end