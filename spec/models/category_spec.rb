require 'rails_helper'

RSpec.describe Category, type: :model do
  # Preparar datos de prueba
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:valid_attributes) {
    {
      name: 'Electronics',
      description: 'Electronic devices and gadgets',
      creator: user
    }
  }

  # Pruebas de asociaciones
  describe 'associations' do
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:categories_products) }
    it { should have_many(:products).through(:categories_products) }
  end

  # Pruebas de validaciones
  describe 'validations' do
    subject { Category.create!(valid_attributes) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:description).is_at_most(500) }
  end

  # Pruebas de creación
  describe 'creation' do
    context 'with valid attributes' do
      it 'creates a new category' do
        category = Category.new(valid_attributes)
        expect(category).to be_valid
        expect(category.save).to be true
      end
    end

    context 'with invalid attributes' do
      it 'fails without a name' do
        category = Category.new(valid_attributes.merge(name: nil))
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include("can't be blank")
      end

      it 'fails with a duplicate name' do
        Category.create!(valid_attributes)
        duplicate = Category.new(valid_attributes)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it 'fails with a description longer than 500 characters' do
        category = Category.new(valid_attributes.merge(description: 'a' * 501))
        expect(category).not_to be_valid
        expect(category.errors[:description]).to include("is too long (maximum is 500 characters)")
      end
    end
  end
end
