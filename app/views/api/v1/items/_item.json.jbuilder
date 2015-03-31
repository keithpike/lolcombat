json.item_id    													item.item_id
json.name																	item.name
json.description 													item.description
json.sanitizedDescription 								item.sanitizedDescription
json.tags    															item.tags
json.requiredChampion											item.requiredChampion unless item.requiredChampion.nil?
json.total_gold    												item.total_gold
json.group    														item.group unless item.group.nil?

json.stats do	
	json.bonusArmor														item.FlatArmorMod unless item.FlatArmorMod.nil?
	json.bonusAttackspeed											item.FlatAttackSpeedMod unless item.FlatAttackSpeedMod.nil?
	json.FlatBlockMod													item.FlatBlockMod unless item.FlatBlockMod.nil?
	json.bonusCrit														item.FlatCritChanceMod unless item.FlatCritChanceMod.nil?
	json.bonusCritdamage											item.FlatCritDamageMod unless item.FlatCritDamageMod.nil?
	json.FlatEXPBonus													item.FlatEXPBonus unless item.FlatEXPBonus.nil?
	json.FlatEnergyPoolMod										item.FlatEnergyPoolMod unless item.FlatEnergyPoolMod.nil?
	json.FlatEnergyRegenMod										item.FlatEnergyRegenMod unless item.FlatEnergyRegenMod.nil?
	json.bonusHp															item.FlatHPPoolMod unless item.FlatHPPoolMod.nil?
	json.bonusHpregen													item.FlatHPRegenMod unless item.FlatHPRegenMod.nil?
	json.bonusMp															item.FlatMPPoolMod unless item.FlatMPPoolMod.nil?
	json.bonusMpregen													item.FlatMPRegenMod unless item.FlatMPRegenMod.nil?
	json.bonusAbilitypower										item.FlatMagicDamageMod unless item.FlatMagicDamageMod.nil?
	json.bonusMovementspeed										item.FlatMovementSpeedMod unless item.FlatMovementSpeedMod.nil?
	json.bonusAttackdamage										item.FlatPhysicalDamageMod unless item.FlatPhysicalDamageMod.nil?
	json.bonusSpellblock											item.FlatSpellBlockMod unless item.FlatSpellBlockMod.nil?
	json.PercentArmorMod											item.PercentArmorMod unless item.PercentArmorMod.nil?
	json.bonusAttackspeed											item.PercentAttackSpeedMod unless item.PercentAttackSpeedMod.nil?
	json.PercentBlockMod											item.PercentBlockMod unless item.PercentBlockMod.nil?
	json.PercentCritChanceMod									item.PercentCritChanceMod unless item.PercentCritChanceMod.nil?
	json.PercentCritDamageMod									item.PercentCritDamageMod unless item.PercentCritDamageMod.nil?
	json.PercentDodgeMod											item.PercentDodgeMod unless item.PercentDodgeMod.nil?
	json.PercentEXPBonus											item.PercentEXPBonus unless item.PercentEXPBonus.nil?
	json.PercentHPPoolMod											item.PercentHPPoolMod unless item.PercentHPPoolMod.nil?
	json.PercentHPRegenMod										item.PercentHPRegenMod unless item.PercentHPRegenMod.nil?
	json.bonusLifesteal												item.PercentLifeStealMod unless item.PercentLifeStealMod.nil?
	json.PercentMPPoolMod											item.PercentMPPoolMod unless item.PercentMPPoolMod.nil?
	json.PercentMPRegenMod										item.PercentMPRegenMod unless item.PercentMPRegenMod.nil?
	json.PercentMagicDamageMod								item.PercentMagicDamageMod unless item.PercentMagicDamageMod.nil?
	json.bonusPercentmovespeed								item.PercentMovementSpeedMod unless item.PercentMovementSpeedMod.nil?
	json.PercentPhysicalDamageMod							item.PercentPhysicalDamageMod unless item.PercentPhysicalDamageMod.nil?
	json.PercentSpellBlockMod									item.PercentSpellBlockMod unless item.PercentSpellBlockMod.nil?
	json.bonusSpellvamp												item.PercentSpellVampMod unless item.PercentSpellVampMod.nil?
	json.rFlatArmorModPerLevel								item.rFlatArmorModPerLevel unless item.rFlatArmorModPerLevel.nil?
	json.rFlatArmorPenetrationMod							item.rFlatArmorPenetrationMod unless item.rFlatArmorPenetrationMod.nil?
	json.rFlatArmorPenetrationModPerLevel			item.rFlatArmorPenetrationModPerLevel unless item.rFlatArmorPenetrationModPerLevel.nil?
	json.rFlatCritChanceModPerLevel						item.rFlatCritChanceModPerLevel unless item.rFlatCritChanceModPerLevel.nil?
	json.rFlatCritDamageModPerLevel						item.rFlatCritDamageModPerLevel unless item.rFlatCritDamageModPerLevel.nil?
	json.rFlatDodgeMod												item.rFlatDodgeMod unless item.rFlatDodgeMod.nil?
	json.rFlatDodgeModPerLevel								item.rFlatDodgeModPerLevel unless item.rFlatDodgeModPerLevel.nil?
	json.rFlatEnergyModPerLevel								item.rFlatEnergyModPerLevel unless item.rFlatEnergyModPerLevel.nil?
	json.rFlatEnergyRegenModPerLevel					item.rFlatEnergyRegenModPerLevel unless item.rFlatEnergyRegenModPerLevel.nil?
	json.rFlatGoldPer10Mod										item.rFlatGoldPer10Mod unless item.rFlatGoldPer10Mod.nil?
	json.rFlatHPModPerLevel										item.rFlatHPModPerLevel unless item.rFlatHPModPerLevel.nil?
	json.rFlatHPRegenModPerLevel							item.rFlatHPRegenModPerLevel unless item.rFlatHPRegenModPerLevel.nil?
	json.rFlatMPModPerLevel										item.rFlatMPModPerLevel unless item.rFlatMPModPerLevel.nil?
	json.rFlatMPRegenModPerLevel							item.rFlatMPRegenModPerLevel unless item.rFlatMPRegenModPerLevel.nil?
	json.rFlatMagicDamageModPerLevel					item.rFlatMagicDamageModPerLevel unless item.rFlatMagicDamageModPerLevel.nil?
	json.rFlatMagicPenetrationMod							item.rFlatMagicPenetrationMod unless item.rFlatMagicPenetrationMod.nil?
	json.rFlatMagicPenetrationModPerLevel			item.rFlatMagicPenetrationModPerLevel unless item.rFlatMagicPenetrationModPerLevel.nil?
	json.rFlatMovementSpeedModPerLevel				item.rFlatMovementSpeedModPerLevel unless item.rFlatMovementSpeedModPerLevel.nil?
	json.rFlatPhysicalDamageModPerLevel				item.rFlatPhysicalDamageModPerLevel unless item.rFlatPhysicalDamageModPerLevel.nil?
	json.rFlatSpellBlockModPerLevel						item.rFlatSpellBlockModPerLevel unless item.rFlatSpellBlockModPerLevel.nil?
	json.rFlatTimeDeadMod											item.rFlatTimeDeadMod unless item.rFlatTimeDeadMod.nil?
	json.rFlatTimeDeadModPerLevel							item.rFlatTimeDeadModPerLevel unless item.rFlatTimeDeadModPerLevel.nil?
	json.rPercentArmorPenetrationMod					item.rPercentArmorPenetrationMod unless item.rPercentArmorPenetrationMod.nil?
	json.rPercentArmorPenetrationModPerLevel	item.rPercentArmorPenetrationModPerLevel unless item.rPercentArmorPenetrationModPerLevel.nil?
	json.rPercentAttackSpeedModPerLevel				item.rPercentAttackSpeedModPerLevel unless item.rPercentAttackSpeedModPerLevel.nil?
	json.rPercentCooldownMod									item.rPercentCooldownMod unless item.rPercentCooldownMod.nil?
	json.rPercentCooldownModPerLevel					item.rPercentCooldownModPerLevel unless item.rPercentCooldownModPerLevel.nil?
	json.rPercentMagicPenetrationMod					item.rPercentMagicPenetrationMod unless item.rPercentMagicPenetrationMod.nil?
	json.rPercentMagicPenetrationModPerLevel	item.rPercentMagicPenetrationModPerLevel unless item.rPercentMagicPenetrationModPerLevel.nil?
	json.rPercentMovementSpeedModPerLevel			item.rPercentMovementSpeedModPerLevel unless item.rPercentMovementSpeedModPerLevel.nil?
	json.rPercentTimeDeadMod									item.rPercentTimeDeadMod unless item.rPercentTimeDeadMod.nil?
	json.rPercentTimeDeadModPerLevel					item.rPercentTimeDeadModPerLevel unless item.rPercentTimeDeadModPerLevel.nil?
end

 json.set! :image do
 	json.partial!('api/v1/images/image', image: item.image) unless item.image.nil?
end
