class AddKeyToAbilities < ActiveRecord::Migration
  def change
    add_column :abilities, :key, :text
  end
end
