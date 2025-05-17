class User < ApplicationRecord
  # Security
  has_secure_password

  # Auditing
  audited

  # Enums
  enum :role, { :client=>0, :admin=>1 }

  # Associations
  has_many :purchases, foreign_key: 'client_id'
  has_many :created_products, class_name: 'Product', foreign_key: 'creator_id'
  has_many :created_categories, class_name: 'Category', foreign_key: 'creator_id'

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
end
