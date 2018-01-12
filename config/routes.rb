Rails.application.routes.draw do
  devise_for :users
  get '/deckbuilder/', to: 'deckbuilder#index', as: 'deckbuilder'
  get '/users/:id', to: 'users#show', as: 'user'
  root to: "home#index", as: 'home'

  resources :cards, only: [:index, :show]
  resources :decklists, only: [:index, :show]
end
