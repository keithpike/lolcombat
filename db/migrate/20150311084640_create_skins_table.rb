class CreateSkinsTable < ActiveRecord::Migration
  def change
    create_table :skins do |t|
    	t.integer :champion_id
      t.integer :skin_id, unique: true
      t.integer :num
      t.text :name
      t.timestamps null: false
    end
    add_index :skins, :champion_id
  end
end
