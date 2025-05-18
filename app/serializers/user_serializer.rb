class UserSerializer < BaseSerializer
  def serializable_hash
    case context[:view]
    when :summary
      summary_hash
    else
      full_hash
    end
  end

  private

  # Full Hash response
  def full_hash
    {
      id: resource.id,
      email: resource.email,
      name: resource.name,
      role: resource.role,
      created_at: resource.created_at,
      updated_at: resource.updated_at
    }
  end

  # Summary Hash response
  def summary_hash
    {
      id: resource.id,
      email: resource.email,
      name: resource.name
    }
  end
end
