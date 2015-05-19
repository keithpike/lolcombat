json.champions @champions do |champion|
	
	json.champion_id 	champion.champion_id
	json.key 					champion.key
	json.name 				champion.name
	json.clean_name		champion.clean_name
	json.title				champion.title
	json.tags 				champion.tags
	json.blurb 				champion.blurb

	json.set! :image do
		json.partial!('api/v1/images/image', image: champion.image) unless champion.image.nil?
	end		
end