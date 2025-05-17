FactoryBot.define do
  factory :purchase do
    client { association :user } # El cliente es un usuario
    product
    quantity { Faker::Number.between(from: 1, to: 10) }
    total_price { quantity * product.price } # Calcula el precio total basado en la cantidad y el precio del producto
  end
end
