json.champion_id 						champion.champion_id
json.key 										champion.key
json.name 									champion.name
json.title 									champion.title
json.lore 									champion.lore
json.allytips 							champion.allytips
json.enemytips 							champion.enemytips
json.tags 									champion.tags
json.resource_type 					champion.resource_type
json.hp 										champion.hp
json.hp_per_level 					champion.hp_per_level
json.mp 										champion.mp
json.mp_per_level 					champion.mp_per_level
json.movespeed 							champion.movespeed
json.armor 									champion.armor
json.armor_per_level 				champion.armor_per_level
json.spellblock 						champion.spellblock
json.spellblock_per_level 	champion.spellblock_per_level
json.attackrange 						champion.attackrange
json.hpregen 								champion.hpregen
json.hpregen_per_level 			champion.hpregen_per_level
json.mpregen 								champion.mpregen
json.mpregen_per_level 			champion.mpregen_per_level
json.crit 									champion.crit
json.crit_per_level 				champion.crit_per_level
json.attackdamage 					champion.attackdamage
json.attackdamage_per_level champion.attackdamage_per_level
json.attackspeedoffset 			champion.attackspeedoffset
json.attackspeed_per_level 	champion.attackspeed_per_level


json.set! :image do
	json.partial!('api/v1/images/image', image: champion.image) unless champion.image.nil?
end
json.set! :splash do
	json.partial!('api/v1/splashes/splash', splash: champion.splashes.first)
end