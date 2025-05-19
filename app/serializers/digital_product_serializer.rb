class DigitalProductSerializer < BaseSerializer
  def serializable_hash
    case context[:view]
    when :summary
      summary_hash
    when :minimal
      minimal_hash
    else
      full_hash
    end
  end

  private

  def full_hash
    {
      id: resource.id,
      name: resource.name,
      description: resource.description,
      price: resource.price,
      download_url: resource.download_url,
      file_size: resource.file_size,
      file_format: resource.file_format,
      creator_id: resource.creator_id,
      created_at: resource.created_at,
      updated_at: resource.updated_at,
      attachments: serialize_attachments
    }
  end

  def summary_hash
    {
      id: resource.id,
      name: resource.name,
      price: resource.price,
      download_url: resource.download_url,
      file_size: resource.file_size,
      file_format: resource.file_format,
      creator_id: resource.creator_id
    }
  end

  def minimal_hash
    {
      id: resource.id,
      name: resource.name,
      price: resource.price
    }
  end

  def serialize_attachments
    return [] unless resource.attachments.loaded?

    resource.attachments.map do |attachment|
      {
        id: attachment.id,
        url: attachment.image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(attachment.image) : nil
      }
    end
  end
end
