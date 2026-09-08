Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"

      resources :produtores, only: %i[index show create update destroy]
      resources :propriedades, only: %i[index show create update destroy]
      resources :culturas, only: %i[index show create update destroy]
      resources :lotes, only: %i[index show create update destroy]
    end
  end
end
