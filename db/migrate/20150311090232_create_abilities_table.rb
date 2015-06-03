class CreateAbilitiesTable < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.integer :champion_id
      t.text :ability_id, unique: true
      t.text :name
      t.text :description
      t.text :tooltip
      t.text :leveltip_label, array: true, default: []
      t.text :leveltip_effect, array: true, default: []
      t.integer :maxrank
      t.float :cooldown, array: true, default: []
      t.text :cooldownBurn
      t.integer :cost, array: true, default: []
      t.text :costBurn
      t.float :effect, array: true, default: []
      t.text :effectBurn, array: true, default: []
      t.text :costType, array: true, default: []
      t.integer :range, array: true, default: []
      t.text :rangeBurn
      t.text :formulas, array: true, default: []

      t.timestamps null: false
    end
    add_index :abilities, :champion_id
  end
end
