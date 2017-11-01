class Decklist < ApplicationRecord
    belongs_to :user
    has_many :decks

    validates :name, presence: true
    validates :name, uniqueness: true
end
