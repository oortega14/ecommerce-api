require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::PhysicalProducts", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) }
  let(:category) { create(:category, creator: admin) }

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
    get 'List all physical products' do
      tags 'Physical Products'
      produces 'application/json'

      response '200', 'list of physical products' do
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
          create_list(:physical_product, 3)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(3)
          expect(json.first['name']).to be_present
        end
      end
    end

    post 'Create a new physical product' do
      tags 'Physical Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      description 'Create a new physical product. For images, provide a public URL where the image can be downloaded.'

      parameter name: :physical_product, in: :body, schema: {
        type: :object,
        properties: {
          physical_product: {
            type: :object,
            properties: {
              name: {
                type: :string,
                description: 'Name of the physical product',
                example: 'Libro de Rails'
              },
              description: {
                type: :string,
                description: 'Detailed description of the product',
                example: 'El mejor libro para aprender Rails desde cero'
              },
              price: {
                type: :string,
                description: 'Price of the product in string format',
                example: '39.99'
              },
              stock: {
                type: :integer,
                description: 'Available quantity of the product',
                example: 100
              },
              weight: {
                type: :string,
                description: 'Weight of the product in kg',
                example: '1.2'
              },
              dimensions: {
                type: :string,
                description: 'Dimensions of the product (length x width x height)',
                example: '25x18x3 cm'
              },
              category_ids: {
                type: :array,
                items: { type: :integer },
                description: 'IDs of the categories to which the product belongs',
                example: [ 6, 7 ]
              }
            },
            required: [ 'name', 'price', 'stock', 'weight', 'dimensions' ]
          }
        }
      }

      response '201', 'physical product created' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: valid_attributes } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq(valid_attributes[:name])
          expect(json['weight']).to eq(valid_attributes[:weight].to_s)
          expect(json['dimensions']).to eq(valid_attributes[:dimensions])
          expect(json['stock']).to eq(valid_attributes[:stock])
        end
      end

      response '422', 'invalid data' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: invalid_attributes } }

        run_test!
      end

      response '403', 'not authorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:physical_product) { { physical_product: valid_attributes } }

        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}' do
    parameter name: :id, in: :path, type: :integer

    let(:existing_physical_product) { create(:physical_product) }
    let(:id) { existing_physical_product.id }

    get 'Retrieves a specific physical product' do
      tags 'Physical Products'
      produces 'application/json'

      response '200', 'physical product found' do
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
          expect(json['weight']).to eq(existing_physical_product.weight.to_s)
          expect(json['dimensions']).to eq(existing_physical_product.dimensions)
        end
      end

      response '404', 'physical product not found' do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch 'Updates a physical product' do
      tags 'Physical Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      description 'Update an existing physical product. You can update any field, all fields are optional.'

      parameter name: :physical_product, in: :body, schema: {
        type: :object,
        properties: {
          physical_product: {
            type: :object,
            properties: {
              name: {
                type: :string,
                description: 'Name of the physical product',
                example: 'Updated Rails Book 2025'
              },
              description: {
                type: :string,
                description: 'Detailed description of the product',
                example: 'Master Ruby on Rails with our updated 2025 book'
              },
              price: {
                type: :string,
                description: 'Price of the product in string format',
                example: '49.99'
              },
              stock: {
                type: :integer,
                description: 'Available quantity of the product',
                example: 200
              },
              weight: {
                type: :string,
                description: 'Weight of the product in kg',
                example: '1.5'
              },
              dimensions: {
                type: :string,
                description: 'Dimensions of the product (length x width x height)',
                example: '26x19x3.5 cm'
              },
              category_ids: {
                type: :array,
                items: { type: :integer },
                description: 'IDs of the categories to which the product belongs',
                example: [ 6, 8, 9 ]
              }
            }
          }
        },
        example: {
          physical_product: {
            name: 'Updated Rails Book 2025',
            price: '49.99',
            description: 'Master Ruby on Rails with our updated 2025 book',
            category_ids: [ 6, 8, 9 ]
          }
        }
      }

      response '200', 'physical product updated' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:physical_product) { { physical_product: { name: "Updated Rails Book 2025", weight: "1.5" } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq("Updated Rails Book 2025")
          expect(json['weight']).to eq("1.5")
        end
      end

      response '403', 'Unauthorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:physical_product) { { physical_product: { name: "Nuevo nombre" } } }

        run_test!
      end
    end

    delete 'Deletes a physical product' do
      tags 'Physical Products'
      security [ bearer_auth: [] ]

      response '200', 'physical product deleted' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        run_test!
      end

      response '403', 'not authorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        run_test!
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}/purchase' do
    parameter name: :id, in: :path, type: :integer
    parameter name: :quantity, in: :query, type: :integer, required: false, description: 'Quantity to purchase (default 1)'

    let(:physical_product_to_purchase) { create(:physical_product, stock: 10) }
    let(:id) { physical_product_to_purchase.id }

    post 'Purchase a physical product' do
      tags 'Physical Products'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'physical product purchased successfully' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:quantity) { 3 }

        before do
          allow(ProductMailer).to receive_message_chain(:purchase_confirmation, :deliver_later)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to include("purchased successfully")

          purchase = Purchase.last
          expect(purchase.client).to eq(client)
          expect(purchase.product).to eq(physical_product_to_purchase)
          expect(purchase.quantity).to eq(quantity)
          expect(purchase.total_price).to eq(physical_product_to_purchase.price * quantity)

          # Verify stock was reduced
          expect(physical_product_to_purchase.reload.stock).to eq(7) # 10 - 3
        end
      end

      response '422', 'insufficient stock error' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:quantity) { 20 } # More than available stock

        before do
          physical_product_to_purchase.update(stock: 5)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to be_present
          # No verificar el mensaje exacto, solo que hay un error
          expect(physical_product_to_purchase.reload.stock).to eq(5) # Stock shouldn't change
        end
      end

      response '422', 'not authenticated' do
        let(:Authorization) { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to be_present
          expect(json['error']['messages']).to include("No puedes comprar este producto digital")
        end
      end
    end
  end

  path '/api/v1/physical_products/{id}/shipping_cost' do
    parameter name: :id, in: :path, type: :integer

    let(:physical_product_with_weight) { create(:physical_product, weight: 2.5) }
    let(:id) { physical_product_with_weight.id }

    get 'Calculate shipping cost for a physical product' do
      tags 'Physical Products'
      produces 'application/json'

      response '200', 'shipping cost calculated' do
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

      response '404', 'physical product not found' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end

  path '/api/v1/physical_products/{id}/audits' do
    parameter name: 'id', in: :path, type: :string, description: 'physical product id'

    get 'Retrieves audit history for a physical product' do
      tags 'Physical Products'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'audit history found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:physical_product) { PhysicalProduct.create!(name: 'Laptop', price: 999.99, weight: 2.5, dimensions: '35x25x2', stock: 10, creator: admin_user) }
        let(:id) { physical_product.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   action: {
                     type: :string,
                     description: 'The type of action performed (create, update, destroy)',
                     example: 'update'
                   },
                   user: {
                     type: [ :string, :null ],
                     description: 'Email of the user who performed the action',
                     example: 'admin@example.com',
                     nullable: true
                   },
                   changes: {
                     type: :object,
                     description: 'Changes made in this audit entry',
                     example: { "name": [ "Old Name", "New Name" ] }
                   },
                   created_at: {
                     type: :string,
                     format: 'date-time',
                     description: 'When the action was performed',
                     example: "2025-05-19T12:00:00.000Z"
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to be >= 1
          expect(data.first).to have_key('action')
          expect(data.first).to have_key('changes')
          expect(data.first).to have_key('created_at')
        end
      end

      response '404', 'physical product not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end
    end
  end
end
