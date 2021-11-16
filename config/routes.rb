Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    post 'authenticate', to: 'authentication#authenticate'
    post 'register', to: 'registration#create_user'

    resources :articles, only: [:index, :create, :update, :destroy] do
      resources :comments, only: [:index, :create, :destroy]
    end
  end
end
