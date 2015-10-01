Rails.application.routes.draw do
  resources :apps, :only => [:index, :create, :update, :destroy]

  get 'monitors/lb' => 'monitors#lb'
  root :to => "apps#index"
end
