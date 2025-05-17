FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Producto #{n}" }
    description { "Descripción del producto" }
    price { 100.0 }
    stock { 10 }
    association :creator, factory: :user, strategy: :create

    # Trait para productos con categorías
    trait :with_categories do
      after(:create) do |product, evaluator|
        product.categories << create(:category)
      end
    end

    # Factory para productos digitales
    factory :digital_product, class: 'DigitalProduct' do
      download_url { "https://example.com/downloads/#{SecureRandom.uuid}" }
      file_size { 1024 } # tamaño en KB
      file_format { [ 'PDF', 'MP3', 'MP4', 'ZIP' ].sample }

      # Los productos digitales no necesitan stock, se establece automáticamente
    end

    # Factory para productos físicos
    factory :physical_product, class: 'PhysicalProduct' do
      weight { rand(0.1..10.0).round(2) } # peso en kg
      dimensions { "#{rand(10..50)}x#{rand(10..50)}x#{rand(1..20)} cm" } # formato: ancho x alto x profundidad
    end
  end
end
