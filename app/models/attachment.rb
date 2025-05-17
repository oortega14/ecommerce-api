class Attachment < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true

  # Attachments
  has_one_attached :image, dependent: :purge_later

  # Callbacks
  before_destroy :purge_image

  # JSON Serialization
  def as_json(options = {})
    result = super(options.except(:include))

    if image.attached?
      # Asegurarnos de que tenemos la configuración de host
      host = Rails.application.routes.default_url_options[:host] || 'localhost:3000'

      # Generar la URL de la imagen
      image_url = Rails.application.routes.url_helpers.rails_blob_url(image, host: host)

      # Agregar la URL al resultado
      result['image_url'] = image_url
    else
      result['image_url'] = nil
    end

    result
  end

  private

  def purge_image
    image.purge if image.attached?
  end
end
