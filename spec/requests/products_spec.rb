require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  # Usar FactoryBot para crear los objetos de prueba
  let(:admin) { create(:user, :admin) }
  let(:client) { create(:user) } # Por defecto, los usuarios son clientes
  let(:category) { create(:category) } # La fábrica ya asocia un creator
  let(:test_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'), 'image/jpeg') }

  describe "POST /api/v1/products" do
    context "como administrador" do
      it "crea un producto con datos válidos" do
        product_attributes = attributes_for(:product)

        expect {
          post "/api/v1/products",
               params: {
                 product: product_attributes.merge(
                   category_ids: [ category.id ],
                   attachments_attributes: [ { image: test_image } ]
                 )
               },
               headers: { 'Authorization' => "Bearer #{token_for(admin)}" }
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)
        expect(data['name']).to eq(product_attributes[:name])
        expect(data['price'].to_f).to eq(product_attributes[:price])
        expect(data['stock']).to eq(product_attributes[:stock])
        expect(data['categories']).to include(hash_including('id' => category.id))
        expect(data['attachments'].length).to eq(1)
        product = Product.find(data['id'])
        expect(product.attachments.count).to eq(1)
      end

      it "devuelve errores con datos inválidos" do
        post "/api/v1/products",
             params: {
               product: {
                 name: '',
                 price: -10,
                 stock: -1,
                 attachments_attributes: [ { image: test_image } ]
               }
             },
             headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['errors']).to include("Name can't be blank")
        expect(data['errors']).to include("Price must be greater than or equal to 0")
        expect(data['errors']).to include("Stock must be greater than or equal to 0")
      end
    end

    context "como cliente" do
      it "devuelve un error de autorización" do
        product_attributes = attributes_for(:product)

        post "/api/v1/products",
             params: {
               product: product_attributes.merge(
                 attachments_attributes: [ { image: test_image } ]
               )
             },
             headers: { 'Authorization' => "Bearer #{token_for(client)}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/products" do
    context "como administrador" do
      it "lista los productos" do
        create(:product, :with_categories, creator: admin)

        get "/api/v1/products", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data.length).to eq(1)
        expect(data.first['name']).to match(/Producto \d+/)
        expect(data.first['categories']).not_to be_empty
      end
    end
  end

  describe "GET /api/v1/products/:id" do
    context "como administrador" do
      it "obtiene un producto" do
        product = create(:product, :with_categories, creator: admin)

        get "/api/v1/products/#{product.id}", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['name']).to eq(product.name)
        expect(data['categories']).not_to be_empty
      end

      it "devuelve un error si el producto no existe" do
        get "/api/v1/products/invalid", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/v1/products/:id" do
    context "como administrador" do
      it "actualiza un producto" do
        product = create(:product, :with_categories, creator: admin)

        patch "/api/v1/products/#{product.id}",
              params: {
                product: {
                  name: 'Updated Laptop',
                  price: 1099.99,
                  stock: 15,
                  category_ids: [ category.id ],
                  attachments_attributes: [ { image: test_image } ]
                }
              },
              headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['name']).to eq('Updated Laptop')
        expect(data['price'].to_f).to eq(1099.99)
        expect(data['stock']).to eq(15)
        expect(data['categories']).to include(hash_including('id' => category.id))
        expect(data['attachments'].length).to eq(1)
        product = Product.find(data['id'])
        expect(product.attachments.count).to eq(1)
      end

      it "puede eliminar imágenes" do
        product = create(:product, :with_categories, creator: admin)
        attachment = product.attachments.create!
        attachment.image.attach(test_image)

        expect(product.reload.attachments.count).to eq(1)

        patch "/api/v1/products/#{product.id}",
              params: {
                product: {
                  attachments_attributes: [ { id: attachment.id, _destroy: true } ]
                }
              },
              headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:ok)
        product = Product.find(product.id)
        expect(product.attachments).to be_empty
      end

      it "devuelve un error si el producto no existe" do
        patch "/api/v1/products/invalid",
              params: {
                product: {
                  name: 'Updated Laptop',
                  price: 1099.99,
                  stock: 15,
                  category_ids: [ category.id ],
                  attachments_attributes: [ { image: test_image } ]
                }
              },
              headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "como cliente" do
      it "devuelve un error de autorización" do
        product = create(:product, :with_categories, creator: admin)

        patch "/api/v1/products/#{product.id}",
              params: {
                product: {
                  name: 'Updated Laptop',
                  price: 1099.99,
                  stock: 15,
                  category_ids: [ category.id ],
                  attachments_attributes: [ { image: test_image } ]
                }
              },
              headers: { 'Authorization' => "Bearer #{token_for(client)}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/products/:id" do
    context "como administrador" do
      it "elimina un producto" do
        product = create(:product, :with_categories, creator: admin)

        expect {
          delete "/api/v1/products/#{product.id}", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }
        }.to change(Product, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(Product.exists?(product.id)).to be_falsey
      end

      it "elimina los adjuntos asociados" do
        product = create(:product, :with_categories, creator: admin)
        attachment = product.attachments.create!
        attachment.image.attach(test_image)

        expect(product.reload.attachments.count).to eq(1)

        expect {
          delete "/api/v1/products/#{product.id}", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }
        }.to change(Attachment, :count).by(-1)
          .and change(ActiveStorage::Attachment, :count).by(-1)
          .and change(ActiveStorage::Blob, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(Product.exists?(product.id)).to be_falsey
      end

      it "devuelve un error si el producto no existe" do
        delete "/api/v1/products/invalid", headers: { 'Authorization' => "Bearer #{token_for(admin)}" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "como cliente" do
      it "devuelve un error de autorización" do
        product = create(:product, :with_categories, creator: admin)

        delete "/api/v1/products/#{product.id}", headers: { 'Authorization' => "Bearer #{token_for(client)}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
