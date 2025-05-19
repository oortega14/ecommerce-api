class PurchaseSerializer < BaseSerializer
  def serializable_hash
    case context[:view]
    when :summary
      summary_hash
    else
      full_hash
    end
  end

  private

  def full_hash
    {
      id: resource.id,
      client_id: resource.client_id,
      product_id: resource.product_id,
      quantity: resource.quantity,
      total_price: resource.total_price,
      created_at: resource.created_at,
      updated_at: resource.updated_at
    }
  end

  def summary_hash
    {
      id: resource.id,
      client_id: resource.client_id,
      product_id: resource.product_id,
      quantity: resource.quantity,
      total_price: resource.total_price
    }
  end
end
