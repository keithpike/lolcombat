class AddCleannameToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :clean_name, :string
    add_index :champions, :clean_name
  end
end
