FactoryBot.define do
  factory :attachment do
    sequence(:name) { |n| "Archivo #{n}" }
    url { "https://example.com/sample-image.jpg" }
    file_type { "image/jpeg" }
    
    # No definimos una asociacion por defecto para evitar circularidad
    # En su lugar, usamos traits para diferentes tipos de registros
    
    trait :for_product do
      association :record, factory: :product
    end
    
    # Para usar con otros modelos polimorficos si es necesario
    trait :for_user do
      association :record, factory: :user
    end
  end
end