class Product < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User'

  has_many :categories_products, dependent: :destroy
  has_many :categories, through: :categories_products
  has_many :purchases, dependent: :destroy

  has_many :attachments, as: :record, dependent: :destroy

  # Nested Attributes
  accepts_nested_attributes_for :attachments, allow_destroy: true

  # Auditing
  audited

  # Validations
  validates :name, :price, :stock, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  # JSON Serialization
  def as_json(options = {})
    # Crear una copia de las opciones para no modificar las originales
    attachment_options = {}

    super(options).merge({
      # Incluir el tipo de producto (para STI)
      type: type,
      # Serializar los adjuntos sin pasar las opciones que podrían causar problemas
      attachments: attachments.map { |attachment| attachment.as_json(attachment_options) }
    })
  end
end
