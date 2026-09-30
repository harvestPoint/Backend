Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :auth do
      post :signup, to: "registrations#create"
      post :login, to: "sessions#create"
      delete :logout, to: "sessions#destroy"
      get :me, to: "sessions#show"
    end

    resources :lotes
    resources :sensores
    resources :leituras, only: %i[index show create]
    resources :alertas, only: %i[index show update]
    resources :culturas
  end

  # Rotas diretas sem o prefixo /api (flexibilidade para testes e Postman)
  scope module: :api do
    scope :auth, as: :direct_auth do
      post :signup, to: "auth/registrations#create"
      post :login, to: "auth/sessions#create"
      delete :logout, to: "auth/sessions#destroy"
      get :me, to: "auth/sessions#show"
    end

    post :signup, to: "auth/registrations#create"
    post :login, to: "auth/sessions#create"

    resources :lotes
    resources :sensores
    resources :leituras, only: %i[index show create]
    resources :alertas, only: %i[index show update]
    resources :culturas
  end
end
