require 'rails_helper'

RSpec.describe CategoriesProduct, type: :model do
  # Preparar datos de prueba
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:category) { Category.create!(name: 'Electronics', creator: user) }
  let(:product) { Product.create!(name: 'Laptop', price: 999.99, creator: user, stock: 100) }

  # Pruebas de asociaciones
  describe 'associations' do
    it { should belong_to(:category) }
    it { should belong_to(:product) }
  end

  # Pruebas de creación y validación de integridad referencial
  describe 'creation and referential integrity' do
    context 'with valid attributes' do
      it 'creates a valid category-product association' do
        categories_product = CategoriesProduct.new(category: category, product: product)
        expect(categories_product).to be_valid
        expect { categories_product.save! }.not_to raise_error
      end
    end

    context 'with invalid attributes' do
      it 'fails without a category' do
        categories_product = CategoriesProduct.new(product: product)
        expect(categories_product).not_to be_valid
        expect(categories_product.errors[:category]).to include("must exist")
      end

      it 'fails without a product' do
        categories_product = CategoriesProduct.new(category: category)
        expect(categories_product).not_to be_valid
        expect(categories_product.errors[:product]).to include("must exist")
      end

      it 'fails with non-existent category' do
        expect {
          CategoriesProduct.create!(category_id: 999999, product: product)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails with non-existent product' do
        expect {
          CategoriesProduct.create!(category: category, product_id: 999999)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  # Pruebas de eliminación en cascada
  describe 'deletion behavior' do
    let!(:categories_product) { CategoriesProduct.create!(category: category, product: product) }

    it 'is destroyed when category is destroyed' do
      expect { category.destroy }.to change { CategoriesProduct.count }.by(-1)
    end

    it 'is destroyed when product is destroyed' do
      expect { product.destroy }.to change { CategoriesProduct.count }.by(-1)
    end
  end
end
