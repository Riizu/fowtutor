Rails.application.routes.draw do
  devise_for :users
  get '/deckbuilder/', to: 'decklists#new', as: 'deckbuilder'
  get '/users/:id', to: 'users#show', as: 'user'
  root to: "home#index", as: 'home'

  resources :cards, only: [:index, :show] do
    resources :comments, module: :cards
  end
  
  resources :decklists, only: [:index, :show, :new, :create, :edit, :update] do
    resources :comments, module: :decklists
  end

  resources :users, only: [:show] do
    resources :comments, module: :users
    resources :collections, module: :users do
      resources :cards, only: [:destroy, :update], module: :collections
    end
  end

  namespace :cards do
    resources :search, only: [:create]
  end
end
