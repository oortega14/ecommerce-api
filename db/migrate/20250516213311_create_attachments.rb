class CreateAttachments < ActiveRecord::Migration[7.2]
  def change
    create_table :attachments do |t|
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end
  end
end
