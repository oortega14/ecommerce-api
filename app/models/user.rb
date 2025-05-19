class User < ApplicationRecord
  # Security
  has_secure_password

  # Enums
  enum :role, { :client=>0, :admin=>1 }

  # Associations
  has_many :purchases, foreign_key: 'client_id'
  has_many :created_products, class_name: 'Product', foreign_key: 'creator_id'
  has_many :created_categories, class_name: 'Category', foreign_key: 'creator_id'

  # Validations
  validate :custom_validations

  private

  def custom_validations
    validate_email_presence
    validate_email_uniqueness
    validate_password_length
  end

  def validate_email_presence
    return unless email.blank?
    errors.add(:email, :blank)
    raise ApiExceptions::BaseException.new(:EMAIL_REQUIRED, [], {})
  end

  def validate_email_uniqueness
    return unless email_changed? && User.where.not(id: id || 0).exists?(email: email)
    errors.add(:email, :taken)
    raise ApiExceptions::BaseException.new(:EMAIL_NOT_UNIQUE, [], {})
  end

  def validate_password_length
    return unless password.present? && password.length < 6
    errors.add(:password, :too_short, count: 6)
    raise ApiExceptions::BaseException.new(:PASSWORD_TOO_SHORT, [], {})
  end
end
