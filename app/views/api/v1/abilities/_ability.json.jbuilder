json.name						 				ability.name
json.description			 			ability.description
json.tooltip					 			ability.tooltip
# json.leveltip_label					ability.leveltip_label
# json.leveltip_effect				ability.leveltip_effect
json.maxrank								ability.maxrank
json.cooldown								ability.cooldown
json.cooldownBurn						ability.cooldownBurn
json.cost						 				ability.cost
json.costBurn								ability.costBurn
json.effect									ability.effect
json.effectBurn							ability.effectBurn
json.costType								ability.costType
json.range						 			ability.range
# json.rangeBurn							ability.rangeBurn
json.formulas								ability.formulas
json.key						 				ability.key
json.resource								ability.resource
json.sanitizedDescription		ability.sanitizedDescription
json.sanitizedTooltip				ability.sanitizedTooltip
json.damageType						 	ability.damageType
json.damageFormula				 	ability.damageFormula

json.set! :image do
	json.partial!('api/v1/images/image', image: ability.image) unless ability.image.nil?
end
json.coefficients ability.coefficients do |coefficient|
	json.partial!('api/v1/coefficients/coefficient', coefficient: coefficient) 
end