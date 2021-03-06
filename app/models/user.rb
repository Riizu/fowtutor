class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validate :validate_username

  # Only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  has_many :comments, as: :commentable
  has_many :decklists
  has_many :collections
  has_many :favorites
  has_many :favorite_decklists, through: :favorites, source: :favorited, source_type: 'Decklist'
  has_many :hearts, dependent: :destroy
  has_many :liked_decklists, through: :hearts, source: :decklist
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def heart!(decklist)
    self.hearts.create!(decklist_id: decklist.id)
  end

  def unheart!(decklist)
    heart = self.hearts.find_by_decklist_id(decklist.id)
    heart.destroy!
  end

  def heart?(decklist)
    self.hearts.find_by_decklist_id(decklist.id)
  end
end
