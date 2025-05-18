require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do
  path '/api/v1/sessions' do
    post 'Authenticates user' do
      tags 'Sessions'
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

  path '/api/v1/logout' do
    delete 'Logs out user' do
      tags 'Sessions'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'logged out successfully' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:Authorization) { "Bearer #{token_for(user)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('message')
          expect(data['message']).to eq('Logged out successfully')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end
