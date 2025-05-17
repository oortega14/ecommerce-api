require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let(:client) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
  let(:category) { Category.create!(name: 'Electronics', creator: admin) }
  let(:test_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'), 'image/jpeg') }

  path '/api/v1/products' do
    post 'Creates a product' do
      tags 'Products'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :product, in: :formData, schema: {
        type: :object,
        properties: {
          'product[name]': { type: :string },
          'product[price]': { type: :number },
          'product[stock]': { type: :integer },
          'product[category_ids][]': { type: :array, items: { type: :integer } },
          'product[attachments_attributes][][image]': {
            type: :array,
            items: { type: :string, format: :binary },
            description: 'Array of image files'
          }
        },
        required: [ 'product[name]', 'product[price]', 'product[stock]' ]
      }

      response '201', 'product created' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:product) do
          {
            'product[name]': 'New Laptop',
            'product[price]': 999.99,
            'product[stock]': 10,
            'product[category_ids][]': [ category.id ],
            'product[attachments_attributes][]': {
              image: test_image
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('New Laptop')
          expect(data['price'].to_f).to eq(999.99)
          expect(data['stock']).to eq(10)
          expect(data['categories']).to include(hash_including('id' => category.id))
          expect(data['attachments'].length).to eq(1)
          expect(data['attachments'].first['image_url']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:product) do
          {
            'product[name]': '',
            'product[price]': -10,
            'product[stock]': -1
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include("Name can't be blank")
          expect(data['errors']).to include("Price is not a number")
          expect(data['errors']).to include("Stock is not a number")
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:product) do
          {
            'product[name]': 'New Laptop',
            'product[price]': 999.99,
            'product[stock]': 10
          }
        end

        run_test!
      end
    end

    get 'Lists products' do
      tags 'Products'
      produces 'application/json'

      response '200', 'products found' do
        before do
          Product.create!(
            name: 'Laptop',
            price: 999.99,
            stock: 10,
            creator: admin,
            categories: [ category ]
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(1)
          expect(data.first['name']).to eq('Laptop')
          expect(data.first['categories']).to include(hash_including('id' => category.id))
        end
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: 'id', in: :path, type: :string

    get 'Retrieves a product' do
      tags 'Products'
      produces 'application/json'

      response '200', 'product found' do
        let(:product) do
          Product.create!(
            name: 'Laptop',
            price: 999.99,
            stock: 10,
            creator: admin,
            categories: [ category ]
          )
        end
        let(:id) { product.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Laptop')
          expect(data['categories']).to include(hash_including('id' => category.id))
        end
      end

      response '404', 'product not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    patch 'Updates a product' do
      tags 'Products'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :product, in: :formData, schema: {
        type: :object,
        properties: {
          'product[name]': { type: :string },
          'product[price]': { type: :number },
          'product[stock]': { type: :integer },
          'product[category_ids][]': { type: :array, items: { type: :integer } },
          'product[attachments_attributes][][image]': {
            type: :array,
            items: { type: :string, format: :binary },
            description: 'Array of image files to add'
          },
          'product[attachments_attributes][][id]': { type: :integer },
          'product[attachments_attributes][][_destroy]': { type: :boolean }
        }
      }

      response '200', 'product updated' do
        let(:existing_product) do
          Product.create!(
            name: 'Old Laptop',
            price: 899.99,
            stock: 5,
            creator: admin,
            categories: [ category ]
          )
        end
        let(:id) { existing_product.id }
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:product) do
          {
            'product[name]': 'Updated Laptop',
            'product[price]': 1099.99,
            'product[stock]': 15,
            'product[category_ids][]': [ category.id ],
            'product[attachments_attributes][]': {
              image: test_image
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Updated Laptop')
          expect(data['price'].to_f).to eq(1099.99)
          expect(data['stock']).to eq(15)
          expect(data['categories']).to include(hash_including('id' => category.id))
          expect(data['attachments'].length).to eq(1)
          expect(data['attachments'].first['image_url']).to be_present
        end

        it 'can remove images' do
          # Primero creamos un attachment
          attachment = existing_product.attachments.create!
          attachment.image.attach(test_image)

          # Luego intentamos eliminarlo
          patch "/api/v1/products/#{id}", params: {
            product: {
              attachments_attributes: [
                { id: attachment.id, _destroy: true }
              ]
            }
          }, headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

          expect(response).to have_http_status(:success)
          expect(existing_product.reload.attachments).to be_empty
        end
      end

      response '401', 'unauthorized' do
        let(:existing_product) do
          Product.create!(
            name: 'Old Laptop',
            price: 899.99,
            stock: 5,
            creator: admin
          )
        end
        let(:id) { existing_product.id }
        let(:Authorization) { "Bearer #{token_for(client)}" }
        let(:product) do
          {
            'product[name]': 'Updated Laptop'
          }
        end

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin)}" }
        let(:product) do
          {
            'product[name]': 'Updated Laptop'
          }
        end

        run_test!
      end
    end

    delete 'Deletes a product' do
      tags 'Products'
      security [ bearer_auth: [] ]

      response '204', 'product deleted' do
        let(:existing_product) do
          Product.create!(
            name: 'Old Laptop',
            price: 899.99,
            stock: 5,
            creator: admin
          )
        end
        let(:id) { existing_product.id }
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        run_test! do
          expect(Product.exists?(id)).to be_falsey
        end

        it 'deletes associated attachments' do
          # Crear un attachment
          attachment = existing_product.attachments.create!
          attachment.image.attach(test_image)

          expect {
            delete "/api/v1/products/#{id}", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }
          }.to change(Attachment, :count).by(-1)
            .and change(ActiveStorage::Attachment, :count).by(-1)
            .and change(ActiveStorage::Blob, :count).by(-1)
        end
      end

      response '401', 'unauthorized' do
        let(:existing_product) do
          Product.create!(
            name: 'Old Laptop',
            price: 899.99,
            stock: 5,
            creator: admin
          )
        end
        let(:id) { existing_product.id }
        let(:Authorization) { "Bearer #{token_for(client)}" }

        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin)}" }

        run_test!
      end
    end
  end
end
