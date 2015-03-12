class CreateImagesTable < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :full
      t.text :sprite
      t.text :group
      t.integer :x
      t.integer :y
      t.integer :w
      t.integer :h
      t.timestamps null: false
    end
    add_index :images, :full
  end
end
