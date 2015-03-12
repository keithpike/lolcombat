class CreateAbilitiesTable < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.text :champion_key
      t.text :ability_id, unique: true
      t.text :name
      t.text :description
      t.text :tooltip
      t.text :leveltip_label, array: true, default: []
      t.text :leveltip_effect, array: true, default: []
      t.integer :maxrank
      t.integer :cooldown, array: true, default: []
      t.text :cooldownBurn
      t.integer :cost, array: true, default: []
      t.text :costBurn
      t.integer :effect
      t.text :effectBurn, array: true, default: []
      t.text :costType
      t.integer :range, array: true, default: []
      t.text :rangeBurn

      t.timestamps null: false
    end
    add_index :abilities, :champion_key
  end
end
