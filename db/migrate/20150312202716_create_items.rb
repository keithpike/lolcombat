class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
    	t.text :name
    	t.text :item_id
    	t.text :description
    	t.text :sanitizedDescription
    	t.text :tags, array: true, default: []
    	t.text :requiredChampion
    	t.integer :total_gold
    	t.text :group
	    t.float :FlatHPPoolMod
			t.float :rFlatHPModPerLevel
			t.float :FlatMPPoolMod
			t.float :rFlatMPModPerLevel
			t.float :PercentHPPoolMod
			t.float :PercentMPPoolMod
			t.float :FlatHPRegenMod
			t.float :rFlatHPRegenModPerLevel
			t.float :PercentHPRegenMod
			t.float :FlatMPRegenMod
			t.float :rFlatMPRegenModPerLevel
			t.float :PercentMPRegenMod
			t.float :FlatArmorMod
			t.float :rFlatArmorModPerLevel
			t.float :PercentArmorMod
			t.float :rFlatArmorPenetrationMod
			t.float :rFlatArmorPenetrationModPerLevel
			t.float :rPercentArmorPenetrationMod
			t.float :rPercentArmorPenetrationModPerLevel
			t.float :FlatPhysicalDamageMod
			t.float :rFlatPhysicalDamageModPerLevel
			t.float :PercentPhysicalDamageMod
			t.float :FlatMagicDamageMod
			t.float :rFlatMagicDamageModPerLevel
			t.float :PercentMagicDamageMod
			t.float :FlatMovementSpeedMod
			t.float :rFlatMovementSpeedModPerLevel
			t.float :PercentMovementSpeedMod
			t.float :rPercentMovementSpeedModPerLevel
			t.float :FlatAttackSpeedMod
			t.float :PercentAttackSpeedMod
			t.float :rPercentAttackSpeedModPerLevel
			t.float :rFlatDodgeMod
			t.float :rFlatDodgeModPerLevel
			t.float :PercentDodgeMod
			t.float :FlatCritChanceMod
			t.float :rFlatCritChanceModPerLevel
			t.float :PercentCritChanceMod
			t.float :FlatCritDamageMod
			t.float :rFlatCritDamageModPerLevel
			t.float :PercentCritDamageMod
			t.float :FlatBlockMod
			t.float :PercentBlockMod
			t.float :FlatSpellBlockMod
			t.float :rFlatSpellBlockModPerLevel
			t.float :PercentSpellBlockMod
			t.float :FlatEXPBonus
			t.float :PercentEXPBonus
			t.float :rPercentCooldownMod
			t.float :rPercentCooldownModPerLevel
			t.float :rFlatTimeDeadMod
			t.float :rFlatTimeDeadModPerLevel
			t.float :rPercentTimeDeadMod
			t.float :rPercentTimeDeadModPerLevel
			t.float :rFlatGoldPer10Mod
			t.float :rFlatMagicPenetrationMod
			t.float :rFlatMagicPenetrationModPerLevel
			t.float :rPercentMagicPenetrationMod
			t.float :rPercentMagicPenetrationModPerLevel
			t.float :FlatEnergyRegenMod
			t.float :rFlatEnergyRegenModPerLevel
			t.float :FlatEnergyPoolMod
			t.float :rFlatEnergyModPerLevel
			t.float :PercentLifeStealMod
			t.float :PercentSpellVampMod
			t.timestamps
    end
    add_index :items, :item_id
    add_index :items, :name
  end
end
