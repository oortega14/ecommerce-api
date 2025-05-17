FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    name { "Usuario de Prueba" }
    role { :client } # Por defecto, el usuario es un cliente

    trait :admin do
      role { :admin } # Para crear un administrador
    end
  end
end
