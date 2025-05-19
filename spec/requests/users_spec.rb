require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'Lists all client users' do
      tags 'Users'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :view, in: :query, type: :string, required: false, description: 'View type (summary para vista resumida)', enum: [ 'summary' ]

      response '200', 'users found (full view by default)' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(1)
          expect(data.first['email']).to eq('client@example.com')
        end
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'user id'

    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :view, in: :query, type: :string, required: false, description: 'View type (summary para vista resumida)', enum: [ 'summary' ]

      response '200', 'user found (full view by default)' do
        let!(:existing_user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:id) { existing_user.id }
        let(:Authorization) { "Bearer #{token_for(existing_user)}" }
        run_test!
      end

      response '404', 'user not found' do
        let!(:existing_user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:id) { 'non_existent_id' }
        let(:Authorization) { "Bearer #{token_for(existing_user)}" }
        run_test!
      end

      response '200', 'other user details accessible' do
        let!(:existing_user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:id) { existing_user.id }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        run_test!
      end
    end

    patch 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Nuevo Nombre' }
            }
          }
        }
      }

      response '200', 'user updated' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:id) { client_user.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:user) { { user: { name: 'Nuevo Nombre' } } }
        run_test!
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:id) { client_user.id }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        let(:user) { { user: { name: 'Nuevo Nombre' } } }
        run_test!
      end

      response '404', 'user not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'non_existent_id' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        let(:user) { { user: { name: 'Nuevo Nombre' } } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'user deleted' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:id) { client_user.id }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end

      response '403', 'forbidden for non-admin users' do
        let!(:client_user) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
        let(:id) { client_user.id }
        let(:Authorization) { "Bearer #{token_for(client_user)}" }
        run_test!
      end

      response '404', 'user not found' do
        let!(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
        let(:id) { 'non_existent_id' }
        let(:Authorization) { "Bearer #{token_for(admin_user)}" }
        run_test!
      end
    end
  end
end
