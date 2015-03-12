class CreateCoefficientsTable < ActiveRecord::Migration
  def change
    create_table :coefficients do |t|
      t.text :link
      t.integer :ability_id
      t.float :coeff
      t.text :key
      t.timestamps null: false
    end
    add_index :coefficients, :ability_id
  end
end
