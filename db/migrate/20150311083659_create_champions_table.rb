class CreateChampionsTable < ActiveRecord::Migration
  def change
    create_table :champions do |t|
      t.text :champion_id, unique: true
      t.text :key, unique: true
      t.text :name
      t.text :title
      t.text :lore
      t.text :blurb
      t.text :allytips, array: true, default: []
      t.text :enemytips, array: true, default: []
      t.text :tags, array: true, default: []
      t.text :resource_type
      t.float :hp
      t.float :hp_per_level
      t.float :mp
      t.float :mp_per_level
      t.float :movespeed
      t.float :armor
      t.float :armor_per_level
      t.float :spellblock
      t.float :spellblock_per_level
      t.float :attackrange
      t.float :hpregen
      t.float :hpregen_per_level
      t.float :mpregen
      t.float :mpregen_per_level
      t.float :crit
      t.float :crit_per_level
      t.float :attackdamage
      t.float :attackdamage_per_level
      t.float :attackspeedoffset
      t.float :attackspeed_per_level
      t.timestamps null: false
    end
    add_index :champions, :key
  end
end
