class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :stock
      t.string :type
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
