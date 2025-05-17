require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::PhysicalProducts", type: :request do
  # Crear datos de prueba
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) }
  let(:category) { create(:category, creator: admin) }

  # Atributos vu00e1lidos para un producto fu00edsico
  let(:valid_attributes) do
    {
      name: "Libro de Rails",
      description: "El mejor libro para aprender Rails",
      price: 39.99,
      stock: 100,
      weight: 1.2,
      dimensions: "25x18x3 cm",
      category_ids: [ category.id ]
    }
  end

  # Atributos invu00e1lidos para un producto fu00edsico
  let(:invalid_attributes) do
    {
      name: "",
      price: -10,
      stock: -5,
      weight: 0,
      dimensions: ""
    }
  end

  path '/api/v1/physical_products' do
    get 'Lista todos los productos fu00edsicos' do
      tags 'Productos Fu00edsicos'
      produces 'application/json'

      response '200', 'lista de productos fu00edsicos' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   description: { type: :string },
                   price: { type: :string },
                   stock: { type: :integer },
                   type: { type: :string },
                   weight: { type: :string },
                   dimensions: { type: :string },
                   creator_id: { type: :integer },
                   created_at: { type: :string, format: 'date-time' },
                   updated_at: { type: :string, format: 'date-time' },
                   categories: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string }
                       }
                     }
                   },
                   attachments: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         url: { type: :string }
                       }
                     }
                   }
                 }
               }

        before do
          # Crear algunos productos fu00edsicos
          create_list(:physical_product, 3)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(3)
          expect(json.first['type']).to eq('PhysicalProduct')
        end
      end
    end

    post 'Crea un nuevo producto fu00edsico' do
      tags 'Productos Fu00edsicos'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :physical_product, in: :body, schema: {
        type: :object,
        properties: {
          physical_product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :string },
              stock: { type: :integer },
              weight: { type: :string },
              dimensions: { type: :string },
              category_ids: {
                type: :array,
                items: { type: :integer }
              }
            },
            required: [ 'name', 'price', 'stock', 'weight', 'dimensions' ]
          }
        }
      }

      response '201', 'producto fu00edsico creado' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: valid_attributes } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq(valid_attributes[:name])
          expect(json['weight']).to eq(valid_attributes[:weight].to_s) # Convertido a string por JSON
          expect(json['dimensions']).to eq(valid_attributes[:dimensions])
          expect(json['stock']).to eq(valid_attributes[:stock])
        end
      end

      response '422', 'datos invu00e1lidos' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: invalid_attributes } }

        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:physical_product) { { physical_product: valid_attributes } }

        run_test!
      end

      response '401', 'no autenticado' do
        let(:Authorization) { nil }
        let(:physical_product) { { physical_product: valid_attributes } }

        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}' do
    parameter name: :id, in: :path, type: :integer

    let(:existing_physical_product) { create(:physical_product) }
    let(:id) { existing_physical_product.id }

    get 'Obtiene un producto fu00edsico especu00edfico' do
      tags 'Productos Fu00edsicos'
      produces 'application/json'

      response '200', 'producto fu00edsico encontrado' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 price: { type: :string },
                 stock: { type: :integer },
                 type: { type: :string },
                 weight: { type: :string },
                 dimensions: { type: :string },
                 creator_id: { type: :integer },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to eq(existing_physical_product.id)
          expect(json['type']).to eq('PhysicalProduct')
          expect(json['weight']).to eq(existing_physical_product.weight.to_s) # Convertido a string por JSON
          expect(json['dimensions']).to eq(existing_physical_product.dimensions)
        end
      end

      response '404', 'producto fu00edsico no encontrado' do
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Actualiza un producto fu00edsico' do
      tags 'Productos Fu00edsicos'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :physical_product, in: :body, schema: {
        type: :object,
        properties: {
          physical_product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :string },
              stock: { type: :integer },
              weight: { type: :string },
              dimensions: { type: :string },
              category_ids: {
                type: :array,
                items: { type: :integer }
              }
            }
          }
        }
      }

      response '200', 'producto fu00edsico actualizado' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: { name: "Libro actualizado", weight: 1.5, stock: 50 } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq("Libro actualizado")
          expect(json['weight']).to eq("1.5")
          expect(json['stock']).to eq(50)
        end
      end

      response '422', 'datos invu00e1lidos' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: { stock: -10 } } }

        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:physical_product) { { physical_product: { name: "Nuevo nombre" } } }

        run_test!
      end
    end

    delete 'Elimina un producto fu00edsico' do
      tags 'Productos Fu00edsicos'
      security [ bearer_auth: [] ]

      response '204', 'producto fu00edsico eliminado' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}/purchase' do
    parameter name: :id, in: :path, type: :integer
    parameter name: :quantity, in: :query, type: :integer, required: false, description: 'Cantidad a comprar (por defecto 1)'

    let(:physical_product_to_purchase) { create(:physical_product, stock: 10) }
    let(:id) { physical_product_to_purchase.id }

    post 'Compra un producto fu00edsico' do
      tags 'Productos Fu00edsicos'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'producto fu00edsico comprado exitosamente' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:quantity) { 3 }

        before do
          # Simular que el mailer funciona
          allow(ProductMailer).to receive_message_chain(:purchase_confirmation, :deliver_later)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to include("Producto físico comprado con éxito")

          # Verificar detalles de la compra
          purchase = Purchase.last
          expect(purchase.client).to eq(client)
          expect(purchase.product).to eq(physical_product_to_purchase)
          expect(purchase.quantity).to eq(quantity)
          expect(purchase.total_price).to eq(physical_product_to_purchase.price * quantity)

          # Verificar que el stock se redujo
          expect(physical_product_to_purchase.reload.stock).to eq(7) # 10 - 3
        end
      end

      response '422', 'error por stock insuficiente' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:quantity) { 20 } # Mu00e1s que el stock disponible

        before do
          physical_product_to_purchase.update(stock: 5)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to include("suficiente stock")
          expect(physical_product_to_purchase.reload.stock).to eq(5) # El stock no debe cambiar
        end
      end

      response '401', 'no autenticado' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}/shipping_cost' do
    parameter name: :id, in: :path, type: :integer

    let(:physical_product_with_weight) { create(:physical_product, weight: 2.5) }
    let(:id) { physical_product_with_weight.id }

    get 'Calcula el costo de envu00edo para un producto fu00edsico' do
      tags 'Productos Fu00edsicos'
      produces 'application/json'

      response '200', 'costo de envu00edo calculado' do
        schema type: :object,
               properties: {
                 shipping_cost: { type: :number }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expected_cost = 5.0 + (2.5 * 0.1) # Base cost + weight factor
          expect(json['shipping_cost']).to eq(expected_cost)
        end
      end

      response '404', 'producto fu00edsico no encontrado' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end
end
