Rails.application.routes.draw do
  devise_for :users
  get '/deckbuilder/', to: 'decklists#new', as: 'deckbuilder'
  get '/users/:id', to: 'users#show', as: 'user'
  get 'tags/:tag', to: 'cards#index', as: :card_tag
  root to: "home#index", as: 'home'

  resources :cards, only: [:index, :show, :edit, :update] do
    resources :comments, module: :cards
  end
  
  resources :decklists do
    resources :comments, module: :decklists
  end

  resources :users, only: [:show] do
    resources :comments, module: :users
    resources :collections, module: :users do
      resources :cards, only: [:destroy, :update], module: :collections
    end
  end

  resources :favorite_decklists, only: [:create, :destroy]

  match 'heart', to: 'hearts#heart', via: :post
  match 'unheart', to: 'hearts#unheart', via: :delete

  namespace :cards do
    resources :search, only: [:create]
  end
end
