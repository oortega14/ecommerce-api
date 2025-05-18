require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  # Pruebas de asociaciones
  describe 'associations' do
    it { should have_many(:purchases) }
    it { should have_many(:created_products).class_name('Product') }
    it { should have_many(:created_categories).class_name('Category') }
  end

  # Pruebas de validaciones personalizadas con excepciones
  describe 'custom validations' do
    context 'email validations' do
      it 'raises EMAIL_REQUIRED exception when email is blank' do
        user = User.new(password: 'password123', password_confirmation: 'password123')
        expect {
          user.save
        }.to raise_error(ApiExceptions::BaseException) do |error|
          expect(error.error_type).to eq(:EMAIL_REQUIRED)
        end
      end

      it 'raises EMAIL_NOT_UNIQUE exception when email is already taken' do
        User.create!(valid_attributes)
        duplicate_user = User.new(valid_attributes)
        expect {
          duplicate_user.save
        }.to raise_error(ApiExceptions::BaseException) do |error|
          expect(error.error_type).to eq(:EMAIL_NOT_UNIQUE)
        end
      end
    end

    context 'password validations' do
      it 'raises PASSWORD_TOO_SHORT exception when password is too short' do
        user = User.new(
          email: 'test2@example.com',
          password: '12345',
          password_confirmation: '12345'
        )
        expect {
          user.save
        }.to raise_error(ApiExceptions::BaseException) do |error|
          expect(error.error_type).to eq(:PASSWORD_TOO_SHORT)
        end
      end
    end
  end

  # Pruebas de enums
  describe 'enums' do
    it { should define_enum_for(:role).with_values(client: 0, admin: 1) }

    context 'when created' do
      subject { User.create!(valid_attributes) }

      it 'defaults to client role' do
        expect(subject.role).to eq('client')
      end
    end
  end

  # Pruebas de autenticación
  describe 'authentication' do
    let(:user) { User.create!(valid_attributes) }

    context 'with valid password' do
      it 'authenticates successfully' do
        expect(user.authenticate('password123')).to eq(user)
      end
    end

    context 'with invalid password' do
      it 'fails authentication' do
        expect(user.authenticate('wrongpassword')).to be false
      end
    end
  end

  # Pruebas de creación
  describe 'creation' do
    context 'with valid attributes' do
      it 'creates a new user' do
        user = User.new(valid_attributes)
        expect { user.save! }.not_to raise_error
      end
    end

    context 'with invalid attributes' do
      it 'requires password confirmation to match' do
        user = User.new(valid_attributes.merge(password_confirmation: 'different'))
        expect(user).not_to be_valid
      end
    end
  end
end
