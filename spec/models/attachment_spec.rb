require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:admin) { User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin') }
  let(:product) { Product.create!(name: 'Laptop', price: 999.99, stock: 100, creator: admin) }

  describe 'associations' do
    it { should belong_to(:record) }
    it { should have_one_attached(:image) }
  end

  describe 'with product' do
    it 'can be attached to a product' do
      attachment = Attachment.new(record: product)
      expect(attachment.record).to eq(product)
    end

    it 'allows multiple attachments per product' do
      attachment1 = Attachment.create!(record: product)
      attachment2 = Attachment.create!(record: product)

      expect(product.attachments.count).to eq(2)
      expect(product.attachments).to include(attachment1, attachment2)
    end
  end

  describe 'with image' do
    let(:attachment) { Attachment.create!(record: product) }

    it 'can attach an image' do
      # Crear un archivo de prueba
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
        'image/jpeg'
      )

      attachment.image.attach(file)
      expect(attachment.image).to be_attached
    end

    it 'can be retrieved with its image' do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
        'image/jpeg'
      )

      attachment.image.attach(file)
      loaded_attachment = Attachment.includes(image_attachment: :blob).find(attachment.id)

      expect(loaded_attachment.image).to be_attached
      expect(loaded_attachment.image.content_type).to eq('image/jpeg')
    end
  end

  describe 'destroying' do
    it 'is destroyed when product is destroyed' do
      attachment = Attachment.create!(record: product)
      expect {
        product.destroy
      }.to change(Attachment, :count).by(-1)
    end

    it 'removes the image when destroyed' do
      attachment = Attachment.create!(record: product)
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
        'image/jpeg'
      )
      attachment.image.attach(file)

      expect {
        attachment.destroy
      }.to change { ActiveStorage::Attachment.count }.by(-1)
        .and change { ActiveStorage::Blob.count }.by(-1)
    end
  end
end
