Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      # Autenticación
      namespace :auth do
        post 'sign_in', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
        post 'sign_up', to: 'registrations#create'
      end

      # Recursos principales
      resources :products
      resources :digital_products do
        member do
          post 'purchase'
        end
      end

      resources :physical_products do
        member do
          post 'purchase'
          get 'shipping_cost'
        end
      end

      resources :categories
      resources :users, except: [ :create ]
      resources :sessions, only: []
      resources :purchases
      resources :attachments

      # Estadísticas
      namespace :stats do
        get 'top_products'
        get 'most_purchased'
        get 'purchases'
        get 'purchase_counts'
      end
    end
  end
end
