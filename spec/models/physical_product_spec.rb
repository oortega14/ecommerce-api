require 'rails_helper'

RSpec.describe PhysicalProduct, type: :model do
  # Configuraciu00f3n de fu00e1bricas para las pruebas
  let(:user) { create(:user) }

  # Atributos vu00e1lidos para crear un producto fu00edsico
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

  # Crear un producto fu00edsico vu00e1lido para las pruebas
  subject(:physical_product) { described_class.new(valid_attributes) }

  # Pruebas de validez bu00e1sica
  describe "validez bu00e1sica" do
    it "es vu00e1lido con atributos vu00e1lidos" do
      expect(physical_product).to be_valid
    end
  end

  # Pruebas de validaciones especu00edficas
  describe "validaciones especu00edficas" do
    it { should validate_presence_of(:weight) }
    it { should validate_presence_of(:dimensions) }
    it { should validate_numericality_of(:weight).is_greater_than(0) }

    it "no es vu00e1lido sin un peso" do
      physical_product.weight = nil
      expect(physical_product).not_to be_valid
    end

    it "no es vu00e1lido con un peso negativo o cero" do
      physical_product.weight = 0
      expect(physical_product).not_to be_valid

      physical_product.weight = -1
      expect(physical_product).not_to be_valid
    end

    it "no es vu00e1lido sin dimensiones" do
      physical_product.dimensions = nil
      expect(physical_product).not_to be_valid
    end

    it "valida que el stock no sea negativo al actualizar" do
      physical_product.save
      physical_product.stock = -5
      expect(physical_product).not_to be_valid
      expect(physical_product.errors[:stock]).to include("no puede ser negativo")
    end
  end

  # Pruebas de comportamiento especu00edfico
  describe "comportamiento especu00edfico" do
    it "requiere envu00edo" do
      expect(physical_product.requires_shipping?).to be true
    end

    it "calcula correctamente el costo de envu00edo" do
      # Base cost (5.0) + weight factor (1.2 * 0.1)
      expected_cost = 5.0 + (1.2 * 0.1)
      expect(physical_product.shipping_cost).to eq(expected_cost)
    end

    it "procesa correctamente una compra" do
      physical_product.save
      client = create(:user)
      initial_stock = physical_product.stock
      quantity = 3

      # Simular que el mailer funciona
      allow(ProductMailer).to receive_message_chain(:purchase_confirmation, :deliver_later)

      expect {
        purchase = physical_product.purchase_by(client, quantity)

        # Verificar que la compra se creu00f3 correctamente
        expect(purchase).to be_persisted
        expect(purchase.client).to eq(client)
        expect(purchase.quantity).to eq(quantity)
        expect(purchase.total_price).to eq(physical_product.price * quantity)

        # Verificar que el stock se redujo
        expect(physical_product.reload.stock).to eq(initial_stock - quantity)
      }.to change(Purchase, :count).by(1)

      # Verificar que se enviu00f3 el correo
      expect(ProductMailer).to have_received(:purchase_confirmation)
    end

    it "lanza un error si no hay suficiente stock" do
      physical_product.stock = 5
      physical_product.save
      client = create(:user)

      expect {
        physical_product.purchase_by(client, 10) # Intentar comprar mu00e1s de lo disponible
      }.to raise_error(StandardError, "No hay suficiente stock disponible")

      # Verificar que el stock no cambiu00f3
      expect(physical_product.reload.stock).to eq(5)
    end
  end

  # Pruebas de factory
  describe "factory" do
    it "crea un producto fu00edsico vu00e1lido con la factory" do
      factory_product = build(:physical_product)
      expect(factory_product).to be_valid
    end

    it "crea un producto fu00edsico con valores predeterminados correctos" do
      factory_product = create(:physical_product)
      expect(factory_product.weight).to be_present
      expect(factory_product.dimensions).to be_present
      expect(factory_product.stock).to be >= 0
    end
  end
end
