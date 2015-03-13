class CreateSplashes < ActiveRecord::Migration
  def change
    create_table :splashes do |t|
    	t.integer :champion_id, index: true
    	t.text :path
    	t.timestamps
    end
  end
end
