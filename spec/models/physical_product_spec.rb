require 'rails_helper'

RSpec.describe PhysicalProduct, type: :model do
  let(:user) { create(:user) }

  let(:valid_attributes) do
    {
      name: "Libro de Rails",
      price: 39.99,
      stock: 100,
      weight: 1.2,
      dimensions: "25x18x3 cm",
      creator: user
    }
  end

  subject(:physical_product) { described_class.new(valid_attributes) }

  describe "Basic validations" do
    it "is valid with valid attributes" do
      expect(physical_product).to be_valid
    end
  end

  describe "Specific validations" do
    it { should validate_presence_of(:weight) }
    it { should validate_presence_of(:dimensions) }
    it { should validate_numericality_of(:weight).is_greater_than(0) }

    it "is not valid without a weight" do
      physical_product.weight = nil
      expect(physical_product).not_to be_valid
    end

    it "is not valid with a weight of zero or negative" do
      physical_product.weight = 0
      expect(physical_product).not_to be_valid

      physical_product.weight = -1
      expect(physical_product).not_to be_valid
    end

    it "is not valid without dimensions" do
      physical_product.dimensions = nil
      expect(physical_product).not_to be_valid
    end

    it "validates that stock is not negative when updating" do
      physical_product.save
      physical_product.stock = -5
      expect(physical_product).not_to be_valid
      expect(physical_product.errors[:stock]).to include("no puede ser negativo")
    end
  end

  describe "Specific behavior" do
    it "requires shipping" do
      expect(physical_product.requires_shipping?).to be true
    end

    it "calculates the shipping cost correctly" do
      # Base cost (5.0) + weight factor (1.2 * 0.1)
      expected_cost = 5.0 + (1.2 * 0.1)
      expect(physical_product.shipping_cost).to eq(expected_cost)
    end

    it "processes a purchase correctly" do
      physical_product.save
      client = create(:user)
      initial_stock = physical_product.stock
      quantity = 3

      allow(ProductMailer).to receive_message_chain(:purchase_confirmation, :deliver_later)

      expect {
        purchase = physical_product.purchase_by(client, quantity)

        expect(purchase).to be_persisted
        expect(purchase.client).to eq(client)
        expect(purchase.quantity).to eq(quantity)
        expect(purchase.total_price).to eq(physical_product.price * quantity)

        expect(physical_product.reload.stock).to eq(initial_stock - quantity)
      }.to change(Purchase, :count).by(1)

      expect(ProductMailer).to have_received(:purchase_confirmation)
    end

    it "raises an error if there is not enough stock" do
      physical_product.stock = 5
      physical_product.save
      client = create(:user)

      expect {
        physical_product.purchase_by(client, 10)
      }.to raise_error(StandardError, "Not enough stock available")

      expect(physical_product.reload.stock).to eq(5)
    end
  end

  describe "factory" do
    it "creates a valid physical product with the factory" do
      factory_product = build(:physical_product)
      expect(factory_product).to be_valid
    end

    it "creates a physical product with default values" do
      factory_product = create(:physical_product)
      expect(factory_product.weight).to be_present
      expect(factory_product.dimensions).to be_present
      expect(factory_product.stock).to be >= 0
    end
  end
end
