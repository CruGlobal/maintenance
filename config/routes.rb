Rails.application.routes.draw do
  resources :apps, only: [:index, :create, :update, :destroy]
  resources :redirects, only: [:index, :create, :update, :destroy]
  resources :vanities, only: [:index, :create, :destroy]
  resources :regexes, only: [:index, :create, :update, :destroy]
  resources :certs, only: [:index, :create, :update, :destroy]
  resources :users, only: [:index, :update, :destroy] do
    collection do
      get :no_access
    end
  end

  get 'monitors/lb' => 'monitors#lb'
  get '/auth/:provider/callback', to: 'sessions#create'
  root to: 'apps#index'
end
