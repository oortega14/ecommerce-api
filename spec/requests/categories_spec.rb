require 'swagger_helper'

RSpec.describe 'Categories API', type: :request do
  path '/api/v1/categories' do
    get 'Lists all categories' do
      tags 'Categories'
      produces 'application/json'
      parameter name: :view, in: :query, type: :string, required: false, description: 'View type (summary para vista resumida)', enum: [ 'summary', 'minimal' ]

      response '200', 'categories found (full view by default)' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let!(:category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.first['name']).to eq('Electronics')
        end
      end
    end

    post 'Creates a category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Electronics' },
              description: { type: :string, example: 'Electronic devices and gadgets' }
            },
            required: [ 'name' ]
          }
        }
      }

      response '201', 'category created' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:category) { { category: { name: 'Electronics', description: 'Electronic devices' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Electronics')
          expect(data['description']).to eq('Electronic devices')
        end
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        let(:category) { { category: { name: 'Electronics', description: 'Electronic devices' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:category) { { category: { description: 'Missing name' } } }
        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'category id'

    get 'Retrieves a category' do
      tags 'Categories'
      produces 'application/json'

      response '200', 'category found (full view by default)' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let!(:category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: user) }
        let(:id) { category.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Electronics')
        end
      end

      response '404', 'category not found' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:id) { 'invalid' }
        run_test!
      end
    end

    patch 'Updates a category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: 'id', in: :path, type: :string
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              product_ids: {
                type: :array,
                items: { type: :integer }
              }
            }
          }
        }
      }

      response '200', 'category updated' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:existing_category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: admin_user) }
        let(:id) { existing_category.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:category) { { category: { name: 'Updated Electronics', description: 'Updated Electronic devices' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Updated Electronics')
        end
      end

      response '200', 'category updated with new products' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:test_category) { Category.create!(name: 'Electronics', creator: admin_user) }
        let!(:product1) { Product.create!(name: 'Laptop', price: 999.99, stock: 100, creator: admin_user) }
        let!(:product2) { Product.create!(name: 'Mouse', price: 29.99, stock: 200, creator: admin_user) }
        let(:id) { test_category.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:category) do
          {
            category: {
              product_ids: [ product1.id, product2.id ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['products'].length).to eq(2)
          expect(data['products'].map { |p| p['id'] }).to include(product1.id, product2.id)
        end
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let!(:existing_category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: client_user) }
        let(:id) { existing_category.id }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        let(:category) { { category: { name: 'Updated Electronics', description: 'Updated Electronic devices' } } }
        run_test!
      end

      response '404', 'category not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:category) { { category: { name: 'Updated Electronics' } } }
        run_test!
      end
    end

    delete 'Deletes a category' do
      tags 'Categories'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'category deleted' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:existing_category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: admin_user) }
        let(:id) { existing_category.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let!(:existing_category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: client_user) }
        let(:id) { existing_category.id }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        run_test!
      end

      response '404', 'category not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}/audits' do
    parameter name: 'id', in: :path, type: :string, description: 'category id'

    get 'Retrieves audit history for a category' do
      tags 'Categories'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'audit history found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:category) { Category.create!(name: 'Electronics', description: 'Electronic devices', creator: admin_user) }
        let(:id) { category.id }
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

      response '404', 'category not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end
    end
  end
end
