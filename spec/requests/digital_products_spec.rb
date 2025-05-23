require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::DigitalProducts", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) }
  let(:category) { create(:category, creator: admin) }

  let(:valid_attributes) do
    {
      name: "Curso de Rails",
      description: "Aprende Rails desde cero",
      price: 49.99,
      download_url: "https://example.com/downloads/rails-course",
      file_size: 2048,
      file_format: "ZIP",
      category_ids: [ category.id ]
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      price: -10,
      download_url: "",
      file_size: 0,
      file_format: ""
    }
  end

  path '/api/v1/digital_products' do
    get 'List all digital products' do
      tags 'Digital Products'
      produces 'application/json'

      response '200', 'list of digital products' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   description: { type: :string },
                   price: { type: :string },
                   type: { type: :string },
                   download_url: { type: :string },
                   file_size: { type: :integer },
                   file_format: { type: :string },
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
          create_list(:digital_product, 3)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(3)
          expect(json.first['name']).to be_present
        end
      end
    end

    post 'Create a new digital product' do
      tags 'Digital Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      description 'Create a new digital product. For images, provide a public URL where the image can be downloaded.'

      parameter name: :digital_product, in: :body, schema: {
        type: :object,
        properties: {
          digital_product: {
            type: :object,
            properties: {
              name: {
                type: :string,
                description: 'Name of the digital product',
                example: 'Curso de Ruby on Rails'
              },
              description: {
                type: :string,
                description: 'Detailed description of the product',
                example: 'Aprende Ruby on Rails desde cero hasta nivel avanzado'
              },
              price: {
                type: :string,
                description: 'Price of the product in string format',
                example: '99.99'
              },
              download_url: {
                type: :string,
                description: 'URL where the digital product can be downloaded',
                example: 'https://example.com/downloads/curso-rails.zip'
              },
              file_size: {
                type: :integer,
                description: 'File size in bytes',
                example: 1024000
              },
              file_format: {
                type: :string,
                description: 'File format (PDF, MP4, ZIP, etc)',
                example: 'ZIP'
              },
              category_ids: {
                type: :array,
                items: { type: :integer },
                description: 'IDs of the categories to which the product belongs',
                example: [ 1, 2 ]
              }
            },
            required: [ 'name', 'price', 'download_url', 'file_size', 'file_format' ]
          }
        }
      }

      response '201', 'digital product created' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:digital_product) { { digital_product: valid_attributes } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq(valid_attributes[:name])
          expect(json['download_url']).to eq(valid_attributes[:download_url])
          expect(json['file_format']).to eq(valid_attributes[:file_format])
        end
      end

      response '422', 'invalid data' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:digital_product) { { digital_product: invalid_attributes } }

        run_test!
      end

      response '403', 'not authorized (not admin)' do
        let(:Authorization) { nil }
        let(:digital_product) { { digital_product: valid_attributes } }

        run_test!
      end
    end
  end

  path '/api/v1/digital_products/{id}' do
    parameter name: :id, in: :path, type: :integer

    let(:existing_digital_product) { create(:digital_product) }
    let(:id) { existing_digital_product.id }

    get 'Retrieves a specific digital product' do
      tags 'Digital Products'
      produces 'application/json'

      response '200', 'digital product found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string },
            price: { type: :string },
            type: { type: :string },
            download_url: { type: :string },
            file_size: { type: :integer },
            file_format: { type: :string },
            creator_id: { type: :integer },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to eq(existing_digital_product.id)
          expect(json['download_url']).to eq(existing_digital_product.download_url)
          expect(json['file_format']).to eq(existing_digital_product.file_format)
        end
      end

      response '404', 'digital product not found' do
        let(:id) { 999999 }
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        run_test!
      end
    end

    patch 'Updates a digital product' do
      tags 'Digital Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      description 'Update an existing digital product. You can update any field, all fields are optional.'

      parameter name: :digital_product, in: :body, schema: {
        type: :object,
        properties: {
          digital_product: {
            type: :object,
            properties: {
              name: {
                type: :string,
                description: 'Name of the digital product',
                example: 'Updated Rails Course 2025'
              },
              description: {
                type: :string,
                description: 'Detailed description of the product',
                example: 'Master Ruby on Rails with our updated 2025 curriculum'
              },
              price: {
                type: :string,
                description: 'Price of the product in string format',
                example: '149.99'
              },
              download_url: {
                type: :string,
                description: 'URL where the digital product can be downloaded',
                example: 'https://example.com/downloads/rails-2025.zip'
              },
              file_size: {
                type: :integer,
                description: 'File size in bytes',
                example: 2048000
              },
              file_format: {
                type: :string,
                description: 'File format (PDF, MP4, ZIP, etc)',
                example: 'ZIP'
              },
              category_ids: {
                type: :array,
                items: { type: :integer },
                description: 'IDs of the categories to which the product belongs',
                example: [ 1, 3, 5 ]
              }
            }
          }
        },
        example: {
          digital_product: {
            name: 'Updated Rails Course 2025',
            price: '149.99',
            description: 'Master Ruby on Rails with our updated 2025 curriculum',
            category_ids: [ 1, 3, 5 ]
          }
        }
      }

      response '200', 'digital product updated' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:digital_product) { { digital_product: { name: "Updated Rails Course 2025", file_format: "ZIP" } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq("Updated Rails Course 2025")
          expect(json['file_format']).to eq("ZIP")
        end
      end

      response '403', 'Unauthorized (not admin)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:digital_product) { { digital_product: { name: "Nuevo nombre" } } }

        run_test!
      end
    end

    delete 'Deletes a digital product' do
      tags 'Digital Products'
      security [ bearer_auth: [] ]

      response '200', 'digital product deleted' do
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

  path '/api/v1/digital_products/{id}/audits' do
    parameter name: 'id', in: :path, type: :string, description: 'digital product id'

    get 'Retrieves audit history for a digital product' do
      tags 'Digital Products'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'audit history found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:digital_product) { DigitalProduct.create!(name: 'E-book', price: 19.99, download_url: 'https://example.com/ebook', file_size: 1024, file_format: 'PDF', stock: 100, creator: admin_user) }
        let(:id) { digital_product.id }
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

      response '404', 'digital product not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end
    end
  end

  path '/api/v1/digital_products/{id}/purchase' do
    parameter name: :id, in: :path, type: :integer

    let(:digital_product_to_purchase) { create(:digital_product) }
    let(:id) { digital_product_to_purchase.id }

    post 'Purchase a digital product' do
      tags 'Digital Products'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'digital product purchased successfully' do
        let(:Authorization) { "Bearer #{token_for(client)}" }

        before do
          allow(ProductMailer).to receive_message_chain(:download_link, :deliver_later)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to include("purchased successfully")

          purchase = Purchase.last
          expect(purchase.client).to eq(client)
          expect(purchase.product).to eq(digital_product_to_purchase)
          expect(purchase.quantity).to eq(1)
          expect(purchase.total_price).to eq(digital_product_to_purchase.price)
        end
      end

      response '422', 'unprocessable entity' do
        let(:Authorization) { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to be_present
          expect(json['error']['messages']).to include("No puedes comprar este producto digital")
        end
      end
    end
  end
end
