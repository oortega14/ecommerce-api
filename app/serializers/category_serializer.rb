class CategorySerializer < BaseSerializer
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
      creator_id: resource.creator_id,
      created_at: resource.created_at,
      updated_at: resource.updated_at,
      products: serialize_products
    }
  end

  # Summary Hash response
  def summary_hash
    {
      id: resource.id,
      name: resource.name,
      description: resource.description,
      creator_id: resource.creator_id,
      created_at: resource.created_at,
      updated_at: resource.updated_at
    }
  end

  # Minimal Hash response
  def minimal_hash
    {
      id: resource.id,
      name: resource.name,
      description: resource.description,
      creator_id: resource.creator_id
    }
  end

  def serialize_products
    return [] unless resource.products.loaded?

    resource.products.map do |product|
      ProductSerializer.new(product, context: { view: :summary }).serializable_hash
    end
  end
end
