class CreateSkinsTable < ActiveRecord::Migration
  def change
    create_table :skins do |t|
    	t.text :champion_key
      t.integer :skin_id, unique: true
      t.integer :num
      t.text :name
      t.timestamps null: false
    end
    add_index :skins, :champion_key
  end
end
