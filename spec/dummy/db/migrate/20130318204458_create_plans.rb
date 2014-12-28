class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :stripe_id
      t.integer :price_cents
      t.text :features
      t.boolean :highlight
      t.integer :display_order

      t.timestamps
    end
  end
end
