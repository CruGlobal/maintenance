Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "apps#index"

  resources :upstreams
  resources :apps, only: %i[index create update destroy]
  resources :vanities, only: %i[index create destroy]
  resources :regexes, only: %i[index create update destroy]
  resources :users, only: %i[index update destroy] do
    collection do
      get :no_access
    end
  end

  get "monitors/lb" => "monitors#lb"

  resource :sessions, only: %i[new destroy]
  get "auth/oktaoauth/callback", to: "sessions#create"
  match "/logout" => "sessions#destroy", :as => :logout, :via => [:get, :post, :delete]
end
