require 'rails_helper'

RSpec.describe DigitalProduct, type: :model do
  # Configuración de fábricas para las pruebas
  let(:user) { create(:user) }

  # Atributos válidos para crear un producto digital
  let(:valid_attributes) do
    {
      name: "Curso de Rails",
      price: 49.99,
      download_url: "https://example.com/downloads/rails-course",
      file_size: 2048,
      file_format: "ZIP",
      creator: user
    }
  end

  # Crear un producto digital válido para las pruebas
  subject(:digital_product) { described_class.new(valid_attributes) }

  # Pruebas de validez básica
  describe "validez básica" do
    it "es válido con atributos válidos" do
      expect(digital_product).to be_valid
    end
  end

  # Pruebas de validaciones específicas
  describe "validaciones específicas" do
    it { should validate_presence_of(:download_url) }
    it { should validate_presence_of(:file_size) }
    it { should validate_presence_of(:file_format) }
    it { should validate_numericality_of(:file_size).is_greater_than(0) }

    it "no es válido sin una URL de descarga" do
      digital_product.download_url = nil
      expect(digital_product).not_to be_valid
    end

    it "no es válido con un tamaño de archivo negativo o cero" do
      digital_product.file_size = 0
      expect(digital_product).not_to be_valid

      digital_product.file_size = -1
      expect(digital_product).not_to be_valid
    end

    it "no es válido sin un formato de archivo" do
      digital_product.file_format = nil
      expect(digital_product).not_to be_valid
    end
  end

  # Pruebas de comportamiento específico
  describe "comportamiento específico" do
    it "no requiere envío" do
      expect(digital_product.requires_shipping?).to be false
    end

    it "establece un stock ilimitado al crear" do
      digital_product.save
      expect(digital_product.stock).to eq(999999)
    end

    it "procesa correctamente una compra" do
      digital_product.save
      client = create(:user)

      # Simular que el mailer funciona
      allow(ProductMailer).to receive_message_chain(:download_link, :deliver_later)

      expect {
        purchase = digital_product.purchase_by(client)

        # Verificar que la compra se creó correctamente
        expect(purchase).to be_persisted
        expect(purchase.client).to eq(client)
        expect(purchase.quantity).to eq(1)
        expect(purchase.total_price).to eq(digital_product.price)
      }.to change(Purchase, :count).by(1)

      # Verificar que se envió el correo
      expect(ProductMailer).to have_received(:download_link).with(client, digital_product)
    end
  end

  # Pruebas de factory
  describe "factory" do
    it "crea un producto digital válido con la factory" do
      factory_product = build(:digital_product)
      expect(factory_product).to be_valid
    end

    it "crea un producto digital con valores predeterminados correctos" do
      factory_product = create(:digital_product)
      expect(factory_product.download_url).to be_present
      expect(factory_product.file_size).to be_present
      expect(factory_product.file_format).to be_present
      expect(factory_product.stock).to eq(999999)
    end
  end
end
