json.items @items do |item|
	json.item_id    	item.item_id
	json.name					item.name
	json.description 	item.description


	json.set! :image do
		json.partial!('api/v1/images/image', image: item.image) unless item.image.nil?
	end		
end