class Category < ApplicationRecord
  # Audited
  audited

  # Associations
  belongs_to :creator, class_name: 'User'

  has_many :categories_products, dependent: :destroy
  has_many :products, through: :categories_products

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true
end
