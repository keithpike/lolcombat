class CreatePassivesTable < ActiveRecord::Migration
  def change
    create_table :passives do |t|
    	t.text :champion_key
      t.text :name, unique: true
      t.text :description
      t.timestamps null: false
    end
    add_index :passives, :champion_key
  end
end
