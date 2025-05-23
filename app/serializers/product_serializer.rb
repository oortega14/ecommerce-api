class ProductSerializer < BaseSerializer
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

  # Full Hash response
  def full_hash
    {
      id: resource.id,
      name: resource.name,
      description: resource.description,
      price: resource.price,
      weight: resource.weight,
      creator_id: resource.creator_id,
      created_at: resource.created_at,
      updated_at: resource.updated_at,
      attachments: serialize_attachments
    }
  end

  # Summary Hash response
  def summary_hash
    {
      id: resource.id,
      name: resource.name,
      price: resource.price,
      attachments: serialize_attachments
    }
  end

  # Minimal Hash response
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
        url: attachment.image.attached? ? attachment.image.url : nil
      }
    end
  end
end
