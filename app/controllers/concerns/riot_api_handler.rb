class RiotApiHandler
	require('json')

	private

	def deep_dup(o)
		Marshal.load(Marshal.dump(o))
	end

	def load_as_json(file)
		JSON.load(IO.read(file))
	end

	def json_modification(some_hash, change_vars, initial_hash_key = nil)
		some_hash = some_hash[initial_hash_key] unless initial_hash_key.nil?
		if some_hash.nil?
			some_hash = {}
		else
			#modifies json hash to include the new variables listed and removes the old variables listed
			begin
				change_vars.each do |vars|
					if vars.last == ""
						some_hash.delete(vars.first) 
					else
						some_hash[vars.last] = some_hash.delete(vars.first)
					end
				end
			rescue
				#throw :notSoGracefulErrorHandling
			end
		end
		some_hash
	end

	def read_all_json_files(directory)
		results = []
		Dir.foreach(directory) do |file|
			next unless file.end_with?(".json")
			results << File.basename(file, File.extname(file))
		end
		results
	end

	def merge_all_hashes!(base_hash, other_hashes)
		other_hashes.each do |other_hash|
			base_hash.merge!(other_hash)
		end
		base_hash
	end

	def create_json_object(received_json, initial_key, initial_key2, base_hash_changes, other_hash_changes)
		changes = []
		other_hash_changes.each do |hash_changes|
			hash_changes_type = hash_changes.pop
			changes << json_modification(received_json[initial_key][initial_key2], hash_changes, hash_changes_type)
			hash_changes << hash_changes_type
		end
		result = json_modification(received_json[initial_key][initial_key2], base_hash_changes)
		merge_all_hashes!(result, changes)

		unless result['image']['full'].nil? || received_json['type'].nil?
			result["image"]["full"] = "#{get_image_path_by_data_type(received_json['type'])}#{result['image']['full']}" 
			result["image"]["sprite"] = "#{get_image_path_by_data_type('sprite')}#{result['image']['sprite']}" 
		end
		result

	end

	def get_json_file_data(path, file_name, initial_key, base_hash_changes, other_hash_changes)
		a = load_as_json("#{path}/#{file_name}.json")
		create_json_object(a, initial_key, file_name, base_hash_changes, other_hash_changes)
	end



	def create_json_objects_from_api(json_data, keys, initial_data_key, base_hash_changes, other_hash_changes)
		results = []
		keys.each do |resource_data_key|
			results << create_json_object(
										json_data, 
										initial_data_key, 
										resource_data_key, 
										base_hash_changes, 
										other_hash_changes
									)
		end
		results
	end

	def create_json_objects_from_files(files, path, initial_key, base_hash_changes, other_hash_changes)
		#expects one format of json files in a single directory with specific changes (max one level deep)
		results = []
		files.each do |file_name|
			# puts file_name
			results << get_json_file_data(
										path,
										file_name, 
										initial_key, 
										base_hash_changes, 
										other_hash_changes
									)
		end
		results
	end

	def get_image_path_by_data_type(data_type)
			case(data_type)
			when "champion"
				'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/champion/'
			when "item"
				'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/item/'
			when "rune"
				'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/rune/'
			when "mastery"
				'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/mastery/'
			when "sprite"
				'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/sprite/'
			else
				[]
			end
	end
	
	def get_modifiers_by_data_type(data_type)
			case(data_type)
			when "champion"
				@champion_modifications
			when "item"
				@item_modifications
			when "rune"
			when "mastery"
			else
				[]
			end
	end

	def get_clean_name(champion_name)
		clean_name = champion_name.split(" ");
		clean_name.map do |name|
			name.slice!(/['\\.]/)
			name.capitalize!	
		end
		clean_name.join("")		
	end

	public

	def initialize()

		

		json_modifications_for_champion = [
			["id", "champion_id"],
			#["image", ""],
			["skins", ""],
			["stats", ""],
			["partype", "resource_type"],
			["info", ""],
			["spells", ""],
			["passive", ""],
			["recommended", ""],
		]

		# quirck in that the last item for any modification item has to be the
		# key value associated in the json object
		champion_stat_modifications = [
			["hpperlevel", "hp_per_level"],
			["mpperlevel", "mp_per_level"],
			["armorperlevel", "armor_per_level"],
			["spellblockperlevel", "spellblock_per_level"],
			["hpregenperlevel", "hpregen_per_level"],
			["mpregenperlevel", "mpregen_per_level"],
			["critperlevel", "crit_per_level"],
			["attackdamageperlevel", "attackdamage_per_level"],
			["attackspeedperlevel", "attackspeed_per_level"],
			"stats"
		]

		json_modifications_for_item = [
			["id", "item_id"],
			#["description", ""],
			#["image", ""],
			["stats", ""],
			["from", ""],
			["depth", ""],
			["effect", ""],
			["maps", ""],
			["hideFromAll", ""],
			["colloq", ""],
			["consumed", ""],
			["plaintext", ""],
			["into", ""],
			["from", ""],
			["stacks", ""],
			["inStore", ""],
			["rune", ""],
			["specialRecipe", ""],
			["consumeOnFull", ""],
			["gold", ""]
		]

		item_gold_modifications = [
			["total", "total_gold"],
			["sell", ""],
			["base", ""],
			["purchasable", ""],
			"gold"
		]

		item_stat_modifications = [
			"stats"
		]


		json_modifications_for_image = []
		json_modifications_for_passive = []
		json_modifications_for_skin = []
		json_modifications_for_ability = []
		json_modifications_for_coefficient = []
		

		@champion_modifications = [ 
			json_modifications_for_champion,
			[
				champion_stat_modifications
			]
		]
		@item_modifications = [
			json_modifications_for_item,
			[
				item_gold_modifications,
				item_stat_modifications
			]
		]
		@ability_modifications = [
			json_modifications_for_ability,
			[]
		]
	end

	# def get_champion(path = nil, champ_name = nil)
	# 	champion = {}
	# 	begin
	# 		return nil if champ_name.nil? || champ_name.empty?  
	# 		initial_key = 'data'
	# 		champion_names = read_all_json_as_champion_files(path, champ_name)
	# 		champion = create_champion_json_objects_from_files(champion_names, path, initial_key, @json_modifications_for_champion, @champion_stat_modifications)
	# 	rescue
	# 	end
	# 	champion
	# end

	def get_resources_from_api(api_data, should_modify = true)
		results = []

		begin
			initial_key = 'data'
			modifiers = should_modify ? get_modifiers_by_data_type(api_data['type']) : [[],[]]
			object_names = api_data[initial_key].keys
			results = create_json_objects_from_api(
												api_data,
												object_names,
												initial_key, 
												modifiers.first, 
												modifiers.last)
		rescue
		end
		results
	end

	def get_resources_from_api_test(path, modify = true)
	  json_resource = load_as_json(path)
	  get_resources_from_api(json_resource, modify)
	end

	def get_resources(path = nil, data_type = nil)
		return nil if path.nil? || get_modifiers_by_data_type(data_type).nil?
		results = []
		begin
			initial_key = 'data'
			modifiers = get_modifiers_by_data_type(data_type)
			object_names = read_all_json_files(path)
			results = create_json_objects_from_files( 
												object_names,
												path, 
												initial_key, 
												modifiers.first, 
												modifiers.last)
		rescue
		end

		results
	end

	def seed_me_seymour_from_files(path)
		seed_data = {}
		seed_data['champions'] = get_resources_from_api_test(path + '/champions.json')
		seed_data['champions'].each do |champion|
			image = champion.delete("image")
			a = Champion.create(champion)
			a.create_image(image)
			splash_path = "https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/splash/#{get_clean_name(a.name)}_0.png"  
			Splash.create({"champion_id" => a.id, "path" => splash_path})
		end
		seed_data['items'] = get_resources_from_api_test(path + '/items.json')
		seed_data['items'].each do |item|
			image = item.delete("image")
			a = Item.create(item)
			a.create_image(image)
		end

	end

	def seed_me_seymour_from_api(urls)
		
	end


end