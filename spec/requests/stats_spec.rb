require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::Stats", type: :request do
  # Crear datos de prueba
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) }

  # Crear categorías
  let!(:category1) { create(:category, name: 'Electrónicos', creator: admin) }
  let!(:category2) { create(:category, name: 'Ropa', creator: admin) }

  # Crear productos
  let!(:product1) { create(:product, name: 'Laptop', price: 1000, stock: 10, creator: admin) }
  let!(:product2) { create(:product, name: 'Teléfono', price: 500, stock: 20, creator: admin) }
  let!(:product3) { create(:product, name: 'Camiseta', price: 25, stock: 50, creator: admin) }

  # Asociar productos con categorías
  before do
    product1.categories << category1
    product2.categories << category1
    product3.categories << category2

    # Crear compras
    # Laptop (product1): 3 unidades en total
    create(:purchase, product: product1, client: client, quantity: 2, total_price: 2000)
    create(:purchase, product: product1, client: client, quantity: 1, total_price: 1000)

    # Teléfono (product2): 5 unidades en total (más que la laptop)
    create(:purchase, product: product2, client: client, quantity: 3, total_price: 1500)
    create(:purchase, product: product2, client: client, quantity: 2, total_price: 1000)

    # Camiseta (product3): 5 unidades
    create(:purchase, product: product3, client: client, quantity: 5, total_price: 125)
  end

  path '/api/v1/stats/top_products' do
    get 'Obtiene los productos más vendidos por cantidad para cada categoría' do
      tags 'Estadísticas'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'lista de productos más vendidos por categoría' do
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
          expect(json.length).to eq(2) # Dos categorías

          # Verificar la primera categoría (Electrónicos)
          electronics = json.find { |cat| cat['category_name'] == 'Electrónicos' }
          expect(electronics).to be_present
          expect(electronics['top_products'].length).to be > 0
          expect(electronics['top_products'].first['name']).to eq('Teléfono') # Más vendido por cantidad

          # Verificar la segunda categoría (Ropa)
          clothing = json.find { |cat| cat['category_name'] == 'Ropa' }
          expect(clothing).to be_present
          expect(clothing['top_products'].length).to be > 0
          expect(clothing['top_products'].first['name']).to eq('Camiseta')
        end
      end

      response '401', 'no autenticado' do
        let(:Authorization) { nil }

        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }

        run_test!
      end
    end
  end

  path '/api/v1/stats/most_purchased' do
    get 'Obtiene los productos que más han recaudado por categoría' do
      tags 'Estadísticas'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Límite de productos por categoría (por defecto 3)'

      response '200', 'lista de productos que más han recaudado por categoría' do
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
          expect(json.length).to eq(2) # Dos categorías

          # Verificar la primera categoría (Electrónicos)
          electronics = json.find { |cat| cat['category_name'] == 'Electrónicos' }
          expect(electronics).to be_present
          expect(electronics['top_products'].length).to be <= 2 # Respeta el límite
          expect(electronics['top_products'].first['name']).to eq('Laptop') # Más recaudación

          # Verificar la segunda categoría (Ropa)
          clothing = json.find { |cat| cat['category_name'] == 'Ropa' }
          expect(clothing).to be_present
          expect(clothing['top_products'].length).to be <= 2 # Respeta el límite
          expect(clothing['top_products'].first['name']).to eq('Camiseta')
        end
      end

      response '401', 'no autenticado' do
        let(:Authorization) { nil }
        let(:limit) { 2 }

        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:limit) { 2 }

        run_test!
      end
    end
  end

  path '/api/v1/stats/purchases' do
    get 'Obtiene listado de compras con filtros opcionales' do
      tags 'Estadísticas'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :start_date, in: :query, type: :string, required: false, description: 'Fecha de inicio (formato YYYY-MM-DD)'
      parameter name: :end_date, in: :query, type: :string, required: false, description: 'Fecha de fin (formato YYYY-MM-DD)'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'ID de la categoría'
      parameter name: :client_id, in: :query, type: :integer, required: false, description: 'ID del cliente'

      response '200', 'listado de compras filtrado' do
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

      context 'con filtro de fecha' do
        let(:start_date) { 2.days.ago.strftime('%Y-%m-%d') }
        let(:end_date) { Date.today.strftime('%Y-%m-%d') }

        response '200', 'compras filtradas por fecha' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(5) # Solo las compras recientes
          end
        end
      end

      context 'con filtro de categoría' do
        let(:category_id) { category2.id }

        response '200', 'compras filtradas por categoría' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(1) # Solo compras de la categoría 'Ropa'
          end
        end
      end

      context 'con filtro de cliente' do
        let(:client_id) { client.id }

        response '200', 'compras filtradas por cliente' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.length).to eq(5) # Solo compras del cliente original
          end
        end
      end

      response '401', 'no autorizado' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path '/api/v1/stats/purchase_counts' do
    get 'Obtiene conteo de compras agrupadas por tiempo' do
      tags 'Estadísticas'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :granularity, in: :query, type: :string, required: false,
                description: 'Granularidad de tiempo (hour, day, week, year)',
                enum: [ 'hour', 'day', 'week', 'year' ]

      response '200', 'conteo de compras agrupadas por tiempo' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        schema type: :object,
               additionalProperties: {
                 type: :integer
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.keys.length).to be >= 1
          expect(json.values.sum).to eq(5) # Total de 5 compras
        end
      end

      context 'con granularidad por hora' do
        let(:granularity) { 'hour' }

        response '200', 'conteo de compras agrupadas por hora' do
          let(:Authorization) { "Bearer #{token_for(admin)}" }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.keys.length).to be >= 1
            expect(json.values.sum).to eq(5) # Total de 5 compras
          end
        end
      end

      response '401', 'no autorizado' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
