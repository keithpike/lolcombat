class AddColumnsToAbilities < ActiveRecord::Migration
  def change
  	add_column :abilities, :resource, :text
  	add_column :abilities, :sanitizedDescription, :text
  	add_column :abilities, :sanitizedTooltip, :text
  	add_column :abilities, :damageType, :text
  end
end
