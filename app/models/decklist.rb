class Decklist < ApplicationRecord
    belongs_to :user
    has_many :decks

    validates :name, presence: true
    validates :name, uniqueness: true
    validates :description, presence: true
end
