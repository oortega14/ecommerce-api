class Category < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User'

  has_many :categories_products
  has_many :products, through: :categories_products
end
