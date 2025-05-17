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

  # Pruebas de validaciones
  describe 'validations' do
    subject { User.create!(valid_attributes) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    context 'password validations' do
      let(:user) { User.new(email: 'test2@example.com') }

      it 'requires minimum length of 6 characters' do
        user.password = user.password_confirmation = '12345'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')

        user.password = user.password_confirmation = '123456'
        expect(user).to be_valid
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
        expect(user).to be_valid
        expect { user.save! }.not_to raise_error
      end
    end

    context 'with invalid attributes' do
      it 'requires password confirmation to match' do
        user = User.new(valid_attributes.merge(password_confirmation: 'different'))
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end
end
