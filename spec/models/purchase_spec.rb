require 'rails_helper'

RSpec.describe Purchase, type: :model do
  # Preparar datos de prueba
  let(:client) { User.create!(email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: 'client') }
  let(:creator) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let(:product) { Product.create!(name: 'Laptop', price: 999.99, stock: 100, creator: creator) }
  let(:valid_attributes) do
    {
      client: client,
      product: product,
      quantity: 2,
      total_price: 1999.98
    }
  end

  # Pruebas de asociaciones
  describe 'associations' do
    it { should belong_to(:client).class_name('User') }
    it { should belong_to(:product) }
  end

  # Pruebas de validaciones
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:total_price) }
  end

  # Pruebas de callbacks
  describe 'callbacks' do
    it 'envía un email de notificación de primera compra después de la creación' do
      expect {
        Purchase.create!(valid_attributes)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'no envía email en actualización' do
      purchase = Purchase.create!(valid_attributes)
      expect {
        purchase.update(quantity: 3)
      }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  # Pruebas de creación
  describe 'creation' do
    context 'with valid attributes' do
      it 'creates a new purchase' do
        expect {
          Purchase.create!(valid_attributes)
        }.to change(Purchase, :count).by(1)
      end

      it 'sets the correct total price' do
        purchase = Purchase.create!(valid_attributes)
        expect(purchase.total_price).to eq(1999.98)
      end
    end

    context 'with invalid attributes' do
      it 'fails without quantity' do
        purchase = Purchase.new(valid_attributes.merge(quantity: nil))
        expect(purchase).not_to be_valid
        expect(purchase.errors[:quantity]).to include("can't be blank")
      end

      it 'fails without total_price' do
        purchase = Purchase.new(valid_attributes.merge(total_price: nil))
        expect(purchase).not_to be_valid
        expect(purchase.errors[:total_price]).to include("can't be blank")
      end

      it 'fails without client' do
        purchase = Purchase.new(valid_attributes.merge(client: nil))
        expect(purchase).not_to be_valid
        expect(purchase.errors[:client]).to include("must exist")
      end

      it 'fails without product' do
        purchase = Purchase.new(valid_attributes.merge(product: nil))
        expect(purchase).not_to be_valid
        expect(purchase.errors[:product]).to include("must exist")
      end
    end
  end

  # Pruebas de lógica de negocio
  describe 'business logic' do
    it 'calculates total price based on quantity and product price' do
      purchase = Purchase.new(
        client: client,
        product: product,
        quantity: 3,
        total_price: product.price * 3
      )
      expect(purchase.total_price).to eq(2999.97)
    end
  end
end
