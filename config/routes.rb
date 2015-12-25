Rails.application.routes.draw do
  resources :apps, :only => [:index, :create, :update, :destroy]
  resources :redirects, :only => [:index, :create, :update, :destroy]
  resources :certs, :only => [:index, :create, :update, :destroy]

  get 'monitors/lb' => 'monitors#lb'
  get '/auth/:provider/callback', to: 'sessions#create'
  root :to => "apps#index"
end
