class Adddamageformulacolumntoabilitiestable < ActiveRecord::Migration
  def change
  	add_column :abilities, :damageFormula, :text
  end
end
