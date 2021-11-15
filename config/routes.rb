Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    post 'authenticate', to: 'authentication#authenticate'
    post 'register', to: 'registration#create_user'
  end
end
