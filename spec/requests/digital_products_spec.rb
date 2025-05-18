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
                   stock: { type: :integer },
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
          # Crear algunos productos digitales
          create_list(:digital_product, 3)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.length).to eq(3)
          expect(json.first['type']).to eq('DigitalProduct')
        end
      end
    end

    post 'Create a new digital product' do
      tags 'Digital Products'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :digital_product, in: :body, schema: {
        type: :object,
        properties: {
          digital_product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :string },
              download_url: { type: :string },
              file_size: { type: :integer },
              file_format: { type: :string },
              category_ids: {
                type: :array,
                items: { type: :integer }
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
          expect(json['stock']).to eq(999999) # Stock ilimitado
        end
      end

      response '422', 'datos invu00e1lidos' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:digital_product) { { digital_product: invalid_attributes } }

        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:digital_product) { { digital_product: valid_attributes } }

        run_test!
      end

      response '401', 'no autenticado' do
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

    get 'Obtiene un producto digital especu00edfico' do
      tags 'Productos Digitales'
      produces 'application/json'

      response '200', 'producto digital encontrado' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 price: { type: :string },
                 stock: { type: :integer },
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
          expect(json['type']).to eq('DigitalProduct')
          expect(json['download_url']).to eq(existing_digital_product.download_url)
          expect(json['file_format']).to eq(existing_digital_product.file_format)
        end
      end

      response '404', 'producto digital no encontrado' do
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Actualiza un producto digital' do
      tags 'Productos Digitales'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :digital_product, in: :body, schema: {
        type: :object,
        properties: {
          digital_product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :string },
              download_url: { type: :string },
              file_size: { type: :integer },
              file_format: { type: :string },
              category_ids: {
                type: :array,
                items: { type: :integer }
              }
            }
          }
        }
      }

      response '200', 'producto digital actualizado' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:digital_product) { { digital_product: { name: "Curso actualizado", file_format: "PDF" } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq("Curso actualizado")
          expect(json['file_format']).to eq("PDF")
        end
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:digital_product) { { digital_product: { name: "Nuevo nombre" } } }

        run_test!
      end
    end

    delete 'Elimina un producto digital' do
      tags 'Productos Digitales'
      security [ bearer_auth: [] ]

      response '204', 'producto digital eliminado' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        run_test!
      end

      response '403', 'no autorizado (no es administrador)' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        run_test!
      end
    end
  end

  path '/api/v1/digital_products/{id}/purchase' do
    parameter name: :id, in: :path, type: :integer

    let(:digital_product_to_purchase) { create(:digital_product) }
    let(:id) { digital_product_to_purchase.id }

    post 'Compra un producto digital' do
      tags 'Productos Digitales'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'producto digital comprado exitosamente' do
        let(:Authorization) { "Bearer #{token_for(client)}" }

        before do
          # Simular que el mailer funciona
          allow(ProductMailer).to receive_message_chain(:download_link, :deliver_later)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['message']).to include("comprado con u00e9xito")

          # Verificar detalles de la compra
          purchase = Purchase.last
          expect(purchase.client).to eq(client)
          expect(purchase.product).to eq(digital_product_to_purchase)
          expect(purchase.quantity).to eq(1)
          expect(purchase.total_price).to eq(digital_product_to_purchase.price)
        end
      end

      response '401', 'no autenticado' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
