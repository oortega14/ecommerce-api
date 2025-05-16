class Attachment < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true

  # Attachments
  has_one_attached :image
end
