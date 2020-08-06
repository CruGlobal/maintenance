Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :upstreams
  resources :apps, only: %i[index create update destroy]
  resources :redirects, only: %i[index create update destroy]
  resources :vanities, only: %i[index create destroy]
  resources :regexes, only: %i[index create update destroy]
  resources :certs, only: %i[index create update destroy]
  resources :users, only: %i[index update destroy] do
    collection do
      get :no_access
    end
  end

  get "monitors/lb" => "monitors#lb"

  resource :sessions, only: %i[new destroy]
  get "auth/oktaoauth/callback", to: "sessions#create"
  match "/logout" => "sessions#destroy", :as => :logout, :via => [:get, :post, :delete]

  root to: "apps#index"
end
