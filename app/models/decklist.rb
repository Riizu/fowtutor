class Decklist < ApplicationRecord
    belongs_to :user
    has_many :decks
    has_many :comments, as: :commentable

    validates :name, presence: true
    validates :name, uniqueness: true
    validates :description, presence: true
end
