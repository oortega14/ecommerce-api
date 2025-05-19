require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::Stats", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) }

  let!(:category1) { create(:category, name: 'Electrónicos', creator: admin) }
  let!(:category2) { create(:category, name: 'Ropa', creator: admin) }

  let!(:product1) { create(:product, name: 'Laptop', price: 1000, stock: 10, creator: admin) }
  let!(:product2) { create(:product, name: 'Teléfono', price: 500, stock: 20, creator: admin) }
  let!(:product3) { create(:product, name: 'Camiseta', price: 25, stock: 50, creator: admin) }

  before do
    product1.categories << category1
    product2.categories << category1
    product3.categories << category2

    create(:purchase, product: product1, client: client, quantity: 2, total_price: 2000)
    create(:purchase, product: product1, client: client, quantity: 1, total_price: 1000)
    create(:purchase, product: product2, client: client, quantity: 3, total_price: 1500)
    create(:purchase, product: product2, client: client, quantity: 2, total_price: 1000)
    create(:purchase, product: product3, client: client, quantity: 5, total_price: 125)

    create(:purchase, product: product1, client: client, quantity: 2, total_price: 2000)
    create(:purchase, product: product1, client: client, quantity: 1, total_price: 1000)

    create(:purchase, product: product2, client: client, quantity: 3, total_price: 1500)
    create(:purchase, product: product2, client: client, quantity: 2, total_price: 1000)

    create(:purchase, product: product3, client: client, quantity: 5, total_price: 125)
  end

  path '/api/v1/stats/top_products' do
    get 'Get top products by quantity for each category' do
      tags 'Statistics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'list of top products by quantity for each category' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   category_name: { type: :string },
                   top_products: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string },
                         quantity_sold: { type: :integer }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(2)

          electronics = json.find { |cat| cat['category_name'] == 'Electrónicos' }
          expect(electronics).to be_present
          expect(electronics['top_products'].length).to be > 0
          expect(electronics['top_products'].first['name']).to eq('Teléfono')

          clothing = json.find { |cat| cat['category_name'] == 'Ropa' }
          expect(clothing).to be_present
          expect(clothing['top_products'].length).to be > 0
          expect(clothing['top_products'].first['name']).to eq('Camiseta')
        end
      end

      response '401', 'Not Authenticated' do
        let(:Authorization) { nil }

        run_test!
      end

      response '403', 'Unauthorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }

        run_test!
      end
    end
  end

  path '/api/v1/stats/most_purchased' do
    get 'Get most purchased products by category' do
      tags 'Statistics'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Limit of products per category (default 3)'

      response '200', 'list of products that have generated the most revenue per category' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:limit) { 2 }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   category_name: { type: :string },
                   top_products: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string },
                         total_revenue: { type: :string }
                       }
                     }
                   }
                 }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(2)

          electronics = json.find { |cat| cat['category_name'] == 'Electronics' }
          expect(electronics).to be_present
          expect(electronics['top_products'].length).to be <= 2
          expect(electronics['top_products'].first['name']).to eq('Laptop')

          clothing = json.find { |cat| cat['category_name'] == 'Ropa' }
          expect(clothing).to be_present
          expect(clothing['top_products'].length).to be <= 2
          expect(clothing['top_products'].first['name']).to eq('Camiseta')
        end
      end

      response '401', 'Not Authenticated' do
        let(:Authorization) { nil }
        let(:limit) { 2 }

        run_test!
      end

      response '403', 'Unauthorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:limit) { 2 }

        run_test!
      end
    end
  end

  path '/api/v1/stats/purchases' do
    get 'Get list of purchases with optional filters' do
      tags 'Statistics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :start_date, in: :query, type: :string, required: false, description: 'Start date (format YYYY-MM-DD)'
      parameter name: :end_date, in: :query, type: :string, required: false, description: 'End date (format YYYY-MM-DD)'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Category ID'
      parameter name: :client_id, in: :query, type: :integer, required: false, description: 'Client ID'

      response '200', 'List of purchases filtered' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   client_id: { type: :integer },
                   product_id: { type: :integer },
                   quantity: { type: :integer },
                   total_price: { type: :string },
                   created_at: { type: :string, format: 'date-time' },
                   product_name: { type: :string },
                   client_email: { type: :string }
                 }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(5) # Cinco compras
        end
      end

      context 'with date filter' do
        let(:start_date) { 2.days.ago.strftime('%Y-%m-%d') }
        let(:end_date) { Date.today.strftime('%Y-%m-%d') }

        response '200', 'List of purchases filtered by date' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(5)
          end
        end
      end

      context 'with category filter' do
        let(:category_id) { category2.id }

        response '200', 'List of purchases filtered by category' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(1)
          end
        end
      end

      context 'with client filter' do
        let(:client_id) { client.id }

        response '200', 'List of purchases filtered by client' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(5)
          end
        end
      end

      response '401', 'Not Authenticated' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path '/api/v1/stats/purchase_counts' do
    get 'Get purchase counts grouped by time' do
      tags 'Statistics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :granularity, in: :query, type: :string, required: false,
                description: 'Time granularity (hour, day, week, year)',
                enum: [ 'hour', 'day', 'week', 'year' ]

      response '200', 'Purchase counts grouped by time' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        schema type: :object,
               additionalProperties: {
                 type: :integer
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.keys.length).to be >= 1
          expect(json.values.sum).to eq(5)
        end
      end

      context 'with hour granularity' do
        let(:granularity) { 'hour' }

        response '200', 'Purchase counts grouped by hour' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.keys.length).to be >= 1
            expect(json.values.sum).to eq(5)
          end
        end
      end

      response '401', 'Not Authenticated' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
