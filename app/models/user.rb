class User < ApplicationRecord
  # Security
  has_secure_password

  # Auditing
  audited

  # Enums
  enum role: { client: 0, admin: 1 }

  # Associations
  has_many :purchases
  has_many :created_products, class_name: 'Product', foreign_key: 'created_by_id'

  # Validations
  validates :email, presence: true, uniqueness: true
end
