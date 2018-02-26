class CardsDatatable < ApplicationDatatable
    private

    def data
        cards.map do |card|
            [].tap do |column|
                if params["source"] == "mini"
                    column << card.code

                    column << ""\
                    '<select class="form-control" id="num-cards">'\
                        '<option value=0>0</option>'\
                        '<option value=1>1</option>'\
                        '<option value=2>2</option>'\
                        '<option value=3>3</option>'\
                        '<option value=4>4</option>'\
                    '</select>'.html_safe
                else
                    column << card.code
                end
                
                column << link_to(card.name, "/cards/#{card.id}")
                if params["source"] == "mini"
                    column << ""\
                    '<div class="btn-group btn-group-sm" role="group">'\
                        '<button type="button" class="btn btn-secondary deck-adjust-button">Main</button>'\
                        '<button type="button" class="btn btn-secondary deck-adjust-button">Stone</button>'\
                        '<button type="button" class="btn btn-secondary deck-adjust-button">Side</button>'\
                        '<button type="button" class="btn btn-secondary deck-adjust-button">Ruler</button>'\
                    "</div>"\
                "".html_safe
                else
                    column << card.card_attribute
                    column << card.card_type
                    column << card.subtype
                end
            end
        end
    end

    def count
        Card.count
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

        puts search_string

        cards = Card.order("#{sort_column} #{sort_direction}")
        cards = cards.page(page).per(per_page)
        cards = cards.where(search_string.join(' or '), search: "%#{params[:search][:value].downcase}%")
    end

    def columns
        if params["source"] == "mini"
            %w(name)
        else
            %w(code name card_attribute card_type subtype)
        end
      end
end