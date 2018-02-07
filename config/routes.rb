Rails.application.routes.draw do
  devise_for :users
  get '/deckbuilder/', to: 'decklists#new', as: 'deckbuilder'
  get '/users/:id', to: 'users#show', as: 'user'
  root to: "home#index", as: 'home'

  resources :cards, only: [:index, :show] do
    resources :comments, module: :cards
  end
  
  resources :decklists, only: [:index, :show, :new, :create] do
    resources :comments, module: :decklists
  end

  resources :users, only: [:show] do
    resources :comments, module: :users
  end
end
