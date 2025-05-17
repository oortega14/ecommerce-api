require 'rails_helper'

RSpec.describe Product, type: :model do
  # Configuración de fábricas para las pruebas
  let(:user) { create(:user) }
  let(:category) { create(:category) }

  # Atributos válidos para crear un producto
  let(:valid_attributes) do
    {
      name: "Producto de prueba",
      price: 100, # Usar un entero en lugar de un decimal para evitar problemas con BigDecimal
      stock: 10,
      creator: user
    }
  end

  # Crear un producto válido para las pruebas
  subject(:product) { described_class.new(valid_attributes) }

  # Pruebas de validez básica
  describe "validez básica" do
    it "es válido con atributos válidos" do
      expect(product).to be_valid
    end
  end

  # Pruebas de asociaciones
  describe "asociaciones" do
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:categories_products).dependent(:destroy) }
    it { should have_many(:categories).through(:categories_products) }
    it { should have_many(:purchases) }
    it { should have_many(:attachments).dependent(:destroy) }
  end

  # Pruebas de validaciones
  describe "validaciones" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:stock) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0) }

    it "no es válido sin un nombre" do
      product.name = nil
      expect(product).not_to be_valid
    end

    it "no es válido con un precio negativo" do
      product.price = -1
      expect(product).not_to be_valid
    end

    it "no es válido con un stock negativo" do
      product.stock = -1
      expect(product).not_to be_valid
    end
  end

  # Pruebas de atributos anidados
  describe "atributos anidados" do
    it { should accept_nested_attributes_for(:attachments).allow_destroy(true) }
  end

  # Pruebas de auditoría
  describe "auditoría" do
    it "está configurado para auditoría" do
      expect(Product).to respond_to(:audited_options)
    end
  end

  # Pruebas de funcionalidad
  describe "funcionalidad" do
    it "puede agregar categorías" do
      product.save
      product.categories << category
      expect(product.categories).to include(category)
    end

    it "puede tener múltiples categorías" do
      product.save
      category1 = create(:category, name: "Categoría 1")
      category2 = create(:category, name: "Categoría 2")
      product.categories << [ category1, category2 ]
      expect(product.categories.count).to eq(2)
    end
  end
end
