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
				throw :notSoGracefulErrorHandling
			end
		end
		some_hash
	end

	def read_all_json_as_champion_files(directory)
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


	def create_champion_json_object(received_json, initial_key, initial_key2, base_hash_changes, other_hash_changes)
		changes = []
		other_hash_changes.each do |hash_changes|
			hash_changes_type = hash_changes.pop
			changes << json_modification(received_json[initial_key][initial_key2], hash_changes, hash_changes_type)
			hash_changes << hash_changes_type
		end
		champion = json_modification(received_json[initial_key][initial_key2], base_hash_changes)
		merge_all_hashes!(champion, changes)
	end

	def get_json_champion(path, file_name, initial_key, base_hash_changes, other_hash_changes)
		a = load_as_json("#{path}/#{file_name}.json")
		create_champion_json_object(a, initial_key, file_name, base_hash_changes, other_hash_changes)
	end

	def create_champion_json_objects_from_files(files, path, initial_key, base_hash_changes, *other_hash_changes)
		#expects one format of json files in a single directory with specific changes (max one level deep)
		champions = []
		files.each do |file_name|
			# puts file_name
			champions << get_json_champion(path, file_name, initial_key, base_hash_changes, other_hash_changes )
		end
		champions
	end

	public

	def initialize()
		@json_modifications_for_images = []
		@json_modifications_for_passives = []
		@json_modifications_for_skins = []
		@json_modifications_for_abilities = []
		@json_modifications_for_coefficients = []

		@json_modifications_for_champion = [
			["id", "champion_id"],
			["image", ""],
			["skins", ""],
			["stats", ""],
			["partype", "resource_type"],
			["info", ""],
			["spells", ""],
			["passive", ""],
			["recommended", ""],
		]

		@stat_modifications = [
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
	end

	def handle_riot_api_champions_all(api_data)
		begin
			initial_key = 'data'
			# champion_names = 
		rescue
		end
	end

	def handle_riot_api_champions_single(api_data)
		initial_key = 'data'
	end

	def seed_me_seymour_from_files(path)
		
	end

	def seed_me_seymour_from_api(url)

	end

	def get_champion(path)
		begin
			initial_key = 'data'
			champion_names = read_all_json_as_champion_files(path)
			champions = create_champion_json_objects_from_files(champion_names, path, initial_key, @json_modifications_for_champion, @stat_modifications)
		rescue
		end
	end

	def get_champions(path = nil)
		champions = []
		begin
			initial_key = 'data'
			champion_names = read_all_json_as_champion_files(path)
			champions = create_champion_json_objects_from_files(champion_names, path, initial_key, @json_modifications_for_champion, @stat_modifications)
		rescue
		end

		champions
	end
end