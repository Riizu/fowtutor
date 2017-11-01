class Cost < ApplicationRecord
    has_many :cards_costs
    has_many :cards, through: :cards_costs

    validates :name, :url, presence: true
    validates :url, uniqueness: true
end
