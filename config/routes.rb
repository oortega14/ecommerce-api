Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :products

      # Rutas para productos digitales
      resources :digital_products do
        member do
          post 'purchase' # POST /api/v1/digital_products/:id/purchase
        end
      end

      # Rutas para productos físicos
      resources :physical_products do
        member do
          post 'purchase' # POST /api/v1/physical_products/:id/purchase
          get 'shipping_cost' # GET /api/v1/physical_products/:id/shipping_cost
        end
      end

      resources :categories
      resources :users
      resources :sessions, only: [ :create ]
      delete 'logout', to: 'sessions#destroy'
      resources :purchases
      resources :attachments

      # Specific Endpoints
      get 'stats/top_products', to: 'stats#top_products'
      get 'stats/most_purchased', to: 'stats#most_purchased'
      get 'stats/purchases', to: 'stats#purchases'
      get 'stats/purchase_counts', to: 'stats#purchase_counts'
    end
  end
end
