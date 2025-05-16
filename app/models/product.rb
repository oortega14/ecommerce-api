class Product < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User'

  has_many :categories_products
  has_many :categories, through: :categories_products
  has_many :purchases

  has_many :attachments, as: :record, dependent: :destroy

  # Auditing
  audited

  # Validations
  validates :name, :price, :stock, presence: true
end
