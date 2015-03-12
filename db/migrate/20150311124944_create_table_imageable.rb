class CreateTableImageable < ActiveRecord::Migration
  def change
    create_table :imageables do |t|
    	t.belongs_to :image, index: true
    	t.references :imageable, polymorphic: true
    	
    	t.timestamps null: false
    end
  end
end
