require 'swagger_helper'

RSpec.describe 'Purchases API', type: :request do
  let(:client) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
  let(:admin) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let(:product) { Product.create!(name: 'Laptop', price: 999.99, stock: 100, creator: admin) }

  path '/api/v1/purchases' do
    get 'Lists purchases' do
      tags 'Purchases'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'purchases found' do
        let(:Authorization) { "Bearer #{token_for(client)}" }

        before do
          # Crear algunas compras para el cliente
          travel_to 1.minute.ago do
            Purchase.create!(client: client, product: product, quantity: 1, total_price: 999.99)
          end

          travel_to Time.current do
            Purchase.create!(client: client, product: product, quantity: 2, total_price: 1999.98)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(2)
          expect(data.first['quantity']).to eq(2)
          expect(data.first['total_price'].to_f).to eq(1999.98)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        run_test!
      end
    end

    post 'Creates a purchase' do
      tags 'Purchases'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :purchase, in: :body, schema: {
        type: :object,
        properties: {
          purchase: {
            type: :object,
            properties: {
              product_id: { type: :integer },
              quantity: { type: :integer }
            },
            required: [ 'product_id', 'quantity' ]
          }
        }
      }

      response '201', 'purchase created' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:purchase) do
          {
            purchase: {
              product_id: product.id,
              quantity: 2
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['quantity']).to eq(2)
          expect(data['total_price'].to_f).to eq(1999.98)
          expect(data['client_id']).to eq(client.id)
          expect(data['product_id']).to eq(product.id)
        end

        it 'enqueues FirstPurchaseEmailJob' do
          expect {
            post '/api/v1/purchases', params: purchase, headers: { 'Authorization' => "Bearer #{token_for(client)}" }
          }.to have_enqueued_job(FirstPurchaseEmailJob)
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:purchase) do
          {
            purchase: {
              product_id: product.id,
              quantity: 0  # Cantidad inválida
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Quantity must be greater than 0')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        let(:purchase) do
          {
            purchase: {
              product_id: product.id,
              quantity: 2
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/purchases/{id}' do
    get 'Retrieves a purchase' do
      tags 'Purchases'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: 'id', in: :path, type: :string

      response '200', 'purchase found' do
        let(:existing_purchase) { Purchase.create!(client: client, product: product, quantity: 2, total_price: 1999.98) }
        let(:id) { existing_purchase.id }
        let(:Authorization) { "Bearer #{token_for(client)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(existing_purchase.id)
          expect(data['quantity']).to eq(2)
          expect(data['total_price'].to_f).to eq(1999.98)
        end
      end

      response '404', 'purchase not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(client)}" }
        run_test! do |response|
          expect(response).to have_http_status(:not_found)
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Purchase not found')
        end
      end

      response '401', 'unauthorized' do
        let(:id) { 'invalid' }
        let(:Authorization) { 'invalid_token' }
        run_test!
      end

      it 'returns 404 for purchase from another user' do
        other_client = User.create!(email: 'other@example.com', password: 'password123', password_confirmation: 'password123', role: 'client')
        other_purchase = Purchase.create!(client: other_client, product: product, quantity: 1, total_price: 999.99)

        get "/api/v1/purchases/#{other_purchase.id}", headers: { 'Authorization' => "Bearer #{token_for(client)}" }
        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['error']).to eq('Purchase not found')
      end
    end
  end
end
