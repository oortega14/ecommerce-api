require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/api/v1/auth/sign_up' do
    post 'Registers a user' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' },
              name: { type: :string, example: 'John Doe' }
            },
            required: [ 'email', 'password', 'name' ]
          }
        }
      }

      response '201', 'user created' do
        let(:user) { { user: { email: 'new@example.com', password: 'password123', password_confirmation: 'password123', name: 'John Doe' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
        end
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'invalid_email' } } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post 'Authenticates user' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      description "Autentica a un usuario y devuelve un token JWT.\n\n"\
                 "Ejemplos que puede utilizar:\n"\
                 "- **Admin login**: { \"user\": { \"email\": \"admin@example.com\", \"password\": \"password\" } }\n"\
                 "- **Client login**: { \"user\": { \"email\": \"cliente1@example.com\", \"password\": \"password\" } }"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: {
                type: :string,
                example: 'admin@example.com'
              },
              password: {
                type: :string,
                example: 'password'
              }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '200', 'user authenticated' do
        let!(:existing_user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:credentials) { { user: { email: existing_user.email, password: 'password123' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { user: { email: 'wrong@email.com', password: 'wrongpass' } } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'Signs out a user' do
      tags 'Auth'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'user signed out' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:Authorization) { "Bearer #{token_for(user)}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end
