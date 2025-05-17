Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :products
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
