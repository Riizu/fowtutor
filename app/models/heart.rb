class Heart < ApplicationRecord
    belongs_to :user
    belongs_to :decklist

    validates :user_id, uniqueness: { scope: :decklist_id }
end
