Rails.application.routes.draw do
  # Health checks para AWS ALB, Route 53 e orquestradores
  get "up" => "rails/health#show", as: :rails_health_check
  get "health", to: "api/health#show"

  namespace :api do
    get :health, to: "health#show"

    namespace :auth do
      post :signup, to: "registrations#create"
      post :login, to: "sessions#create"
      delete :logout, to: "sessions#destroy"
      get :me, to: "sessions#show"
    end

    resources :propriedades
    resources :culturas
    resources :lotes
    resources :sensores do
      collection do
        post :leitura
      end
      member do
        post :leituras, to: "sensores#leitura"
      end
    end
    resources :leituras, only: %i[index create]
    resources :alertas, only: %i[index show update destroy] do
      member do
        patch :resolver
      end
    end
    resources :recomendacoes do
      collection do
        post :gerar
      end
      member do
        patch :aceitar
        patch :rejeitar
      end
    end
    resources :mercado, only: %i[index create]
    resources :clima, only: %i[index create]
    resources :usuarios, only: %i[index show update]
    get :exportacao, to: "exportacao#index"
    get :logistica, to: "logistica#index"
    get :dashboard, to: "dashboard#index"
    get :produtores, to: "usuarios#index"
  end

  # Rotas diretas sem o prefixo /api (para compatibilidade e testes diretos)
  scope module: :api do
    scope :auth, as: :direct_auth do
      post :signup, to: "auth/registrations#create"
      post :login, to: "auth/sessions#create"
      delete :logout, to: "auth/sessions#destroy"
      get :me, to: "auth/sessions#show"
    end

    post :signup, to: "auth/registrations#create"
    post :login, to: "auth/sessions#create"
    delete :logout, to: "auth/sessions#destroy"
    get :me, to: "auth/sessions#show"

    resources :propriedades
    resources :culturas
    resources :lotes
    resources :sensores do
      collection do
        post :leitura
      end
    end
    resources :leituras, only: %i[index create]
    resources :alertas do
      member do
        patch :resolver
      end
    end
    resources :recomendacoes do
      collection do
        post :gerar
      end
      member do
        patch :aceitar
        patch :rejeitar
      end
    end
    resources :mercado, only: %i[index create]
    resources :clima, only: %i[index create]
    resources :usuarios, only: %i[index show update]
    get :exportacao, to: "exportacao#index"
    get :logistica, to: "logistica#index"
    get :dashboard, to: "dashboard#index"
    get :produtores, to: "usuarios#index"
  end
end
