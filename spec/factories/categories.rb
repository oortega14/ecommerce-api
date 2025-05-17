FactoryBot.define do
  factory :category do
    association :creator, factory: :user
    sequence(:name) { |n| "Category #{n}" }
    description { "Description of the category of test" }
  end
end
