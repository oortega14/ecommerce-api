class Attachment < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true

  # Attachments
  has_one_attached :image, dependent: :purge_later

  # Callbacks
  before_destroy :purge_image

  private

  def purge_image
    image.purge if image.attached?
  end
end
