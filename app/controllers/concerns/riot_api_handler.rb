class RiotApiHandler
  require 'json'
  require 'net/http'

  private

  def deep_dup(o)
    Marshal.load(Marshal.dump(o))
  end

  def handle_request(url)
    Net::HTTP.get_response(URI(url))
  end

  # TODO: update to also require version as input
  # put URLS into some config file
  def get_search_url(region)
      "https://#{region}.api.pvp.net/api/lol/#{region}/v4.1/game/ids"
  end

  def get_match_url(region, matchId)
    "https://#{region}.api.pvp.net/api/lol/#{region}/v2.2/match/#{matchId}"
  end

  def get_champions_url(region)
    "https://global.api.pvp.net/api/lol/static-data/#{region}/v1.2/champion"
  end

  def get_items_url(region)
    "https://global.api.pvp.net/api/lol/static-data/#{region}/v1.2/item"
  end

  def add_params(params)
    query_string = "?"
    params.each do |key, value|
      query_string = "#{query_string}#{key}=#{value}&"
    end
    query_string = "#{query_string}api_key=" + ENV['RIOT_API_KEY']
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
      when "ability"
        'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/ability/'
      when "splash"
        'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/splash/'
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
      when "spell"
        @ability_modifications
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
      # ["spells", ""],
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

    champion_ability_modifications = [
      "spells"
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
    
    json_modifications_for_coefficient = []
    

    @champion_modifications = [ 
      json_modifications_for_champion,
      [
        champion_stat_modifications,
        # champion_ability_modifications
      ]
    ]
    @item_modifications = [
      json_modifications_for_item,
      [
        item_gold_modifications,
        item_stat_modifications
      ]
    ]
    @ability_modifications = []
  end

  # def get_champion(path = nil, champ_name = nil)
  #   champion = {}
  #   begin
  #     return nil if champ_name.nil? || champ_name.empty?  
  #     initial_key = 'data'
  #     champion_names = read_all_json_as_champion_files(path, champ_name)
  #     champion = create_champion_json_objects_from_files(champion_names, path, initial_key, @json_modifications_for_champion, @champion_stat_modifications)
  #   rescue
  #   end
  #   champion
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
    # puts results
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
      splash_path = "#{get_image_path_by_data_type('splash')}#{get_clean_name(a.name)}_0.png"  
      Splash.create({"champion_id" => a.id, "path" => splash_path})
    end
    seed_data['items'] = get_resources_from_api_test(path + '/items.json')
    seed_data['items'].each do |item|
      image = item.delete("image")
      a = Item.create(item)
      a.create_image(image)
    end

  end

  def seed_me_seymour_from_api()
    seed_data = {}
    champion_data = handle_request("#{get_champions_url('na')}#{add_params({'champData' => 'all'})}")
    puts 'champion data received from RIOT'
    seed_data['champions'] = get_resources_from_api(JSON.parse(champion_data.body))
    seed_data['champions'].each do |champion|
      image = champion.delete("image")
      spells = champion.delete('spells')
      clean_name = get_clean_name(champion['name'])
      champion.merge!({'clean_name' => clean_name})
      champ = Champion.create(champion)
      champ.create_image(image)
      splash_path = "#{get_image_path_by_data_type('splash')}#{clean_name}_0.png"  
      Splash.create({"champion_id" => champ.id, "path" => splash_path})
      spells.each do |spell|
        image = spell.delete('image')
        image['full'] = "#{get_image_path_by_data_type('ability')}#{image['full']}"
        image['sprite'] = "#{get_image_path_by_data_type('ability')}#{image['sprite']}"
        spell = modify_spell(spell, champion['name'])
        coefficients = spell.delete('coefficients')
        spell.merge!({'champion_id' => champ.id})
        # spell.delete('effect')
        ability = Ability.create(spell)
        ability.create_image(image)
        unless coefficients.nil?
          coefficients.each do |coefficient| 
            coefficient.merge!({'ability_id' => ability.id})
            Coefficient.create(coefficient)
          end
        end
      end

    end
    item_data = handle_request("#{get_items_url('na')}#{add_params({'itemListData' => 'all'})}")
    seed_data['items'] = get_resources_from_api(JSON.parse(item_data.body))
    seed_data['items'].each do |item|
      image = item.delete("image")
      a = Item.create(item)
      a.create_image(image)
    end
  end

  def modify_spell(spell, champion_name)
    formula_count = 0
    formulas = []
    spell.delete('altimages')
    spell.delete('leveltip')
    spell.delete('rangeBurn')
    spell.delete('image')
    spell['resource'] = 'No Cost' if spell['resource'].nil? ||
                                     spell['resource'] == 'Passive ' ||
                                     spell['resource'] == 'Passive' ||
                                     spell['resource'] == 'No Cost '

    spell['damageType'] = parse_damage_type(spell["sanitizedTooltip"])
    # cost[spell['costType'].downcase] = cost[spell['costType'].downcase] ? cost[spell['costType'].downcase] + "," + spell['name'] : spell['name']
    sentences = get_sentences_with_elements(spell['sanitizedTooltip'])
    sentences.each do |sentence|
      rewrite_formulas(get_formulas(sentence[0])).each do |formula|
        formulas << formula
      end
    end
    rewrite_tooltip!(spell['tooltip'], formula_count)
    rewrite_tooltip!(spell['sanitizedTooltip'], formula_count)
    spell['damageFormula'] = parse_damage_formula(spell["sanitizedTooltip"])
    spell['range'] = modify_range(spell['range'])
    formula_count += formulas.length
    new_formulas = rewrite_formulas(get_formulas(spell['resource']))
    spell['resource'] = rewrite_resource(spell['resource'], formula_count)  
    new_formulas.each {|formula| formulas << formula}
    spell['formulas'] = formulas # TODO: Look into change to seperate SQL table
    spell['coefficients'] = modify_spell_variables(spell['vars'], champion_name)
    spell.delete('vars')
    spell['costType'] = spell['costType'].downcase.split(',')
    spell['effect'] = modify_spell_effects(spell['effect'])
    spell
  end

  def modify_spell_effects(effects)
    max_length = 0
    effects.each do |effect|
      max_length = effect.length if !effect.nil? && effect.length > max_length
    end
    effects.map do |effect| 
      effect = [nil] * max_length if effect.nil?
      effect
    end
  end

  def modify_spell_variables(vars, champion_name)
    if vars
      vars.each do |var|
        var.keys.each do |key|
          unless key_variable_wanted?(key)
            var.delete(key)
          end
        end
        var['link'] = handle_special_links(var['link'], champion_name.downcase)
      end
    end
    vars
  end

  def key_variable_wanted?(key)
    key == 'link' ||
    key == 'coeff' ||
    key == 'key'
  end

  def handle_special_links(link, champion)
    special_cases = {
      '@special.jaxrmr' => 'percentabilitypower',
      '@special.jaxrarmor' => 'percentbonusattackdamage',
      '@dynamic.abilitypower' => 'spelldamage',
      '@special.dariusr3' => 'targetstacks',
      '@special.jaycew' => 'text',
      '@dynamic.attackdamage' => 'attackdamage',
      '@special.viw' => 'attackdamagedivided',
      '@special.BraumWArmor' => 'baseplusbonusarmor',   # really hate this implementation
      '@special.BraumWMR' => 'baseplusbonusspellblock', # really hate this implementation
      '@special.nautilusq' => 'ignore',
      '@text' => 'text',
      '@cooldownchampion' => 'cooldownchampion',
      '@stacks' => 'stacks',
      '@text ' => 'text'
    }

    if champion == 'karma' && link == '@text'
      return 'mantralevel'
    end

    return special_cases[link] unless special_cases[link].nil?
    
    return link
  end

# NOTES:

#  @special.jaxrmr =        percentabilitypower
#  @special.jaxrarmor =     percentbonusattackdamage
#  @cooldownchampion =      handles as: @text taking cooldown into effect(differently in each case! Need to test case 2 heimerdinger turrent health)
#  @text =                  handles as: Whatever it says as a cooefficient.
#  @text(for KARMA) =       mantralevel (handles as: @text but linked to karma mantra level)
#  @dynamic.abilitypower =  spelldamage (handles as: now just the formula is no longer consistant, however it is a better initial setup if it were consistent)
#  @special.nautilusq =     @text (handles as: frankly it is handled by e3 so maybe just remove)
#  @stacks =                handles as: @text based on amount of stacks (every time it's different conditions for stack)
#  @special.dariusr3 =      targetstacks (handles as: only Darius! stacks of hemmorage applied to target)
#  @special.jaycew =        @text (handles as: current coefficient is 0 no need to keep AT ALL but it will be applied as @text)
#  @dynamic.attackdamage =  attackdamage (NOTE: Rengar will need custom handling as a value is in the flavor text)
#  @special.viw =           attackdamagedivided (handles as: attack damage divided by coefficient)
#  @special.BraumWArmor =   baseplusbonusarmor
#  @special.BraumWMR =      baseplusbonusspellblock

# {
#                "range": [600, 600, 600, 600, 600],
#                "leveltip": {
#                   "effect": [
#                      "{{ e1 }} -> {{ e1NL }}",
#                      "{{ cooldown }} -> {{ cooldownnNL }}"
#                   ],
#                   "label": [ "Damage", "Cooldown" ]
#                },
#                "resource": "{{ e3 }}% of current Health ",
#                "maxrank": 5,
#                "effectBurn": [ "", "70/115/160/205/250", "22/20/18/16/14", "10", "225", "1" ],
#                "image": {
#                   "w": 48,
#                   "full": "AatroxQ.png",
#                   "sprite": "spell0.png",
#                   "group": "spell",
#                   "h": 48,
#                   "y": 48,
#                   "x": 192
#                },
#                "cooldown": [ 16, 15, 14, 13, 12 ],
#                "cost": [ 0, 0, 0, 0, 0 ],
#                "vars": [{
#                   "link": "bonusattackdamage",
#                   "coeff": [0.6],
#                   "key": "a1"
#                }],
#                "sanitizedDescription": "Aatrox takes flight and slams down at a targeted location, dealing damage and knocking up enemies at the center of impact.",
#                "rangeBurn": "600",
#                "costType": "pofcurrentHealth",
#                "effect": [ 
#                   null,
#                   [ 70, 115, 160, 205, 250 ],
#                   [ 22, 20, 18, 16, 14 ],
#                   [ 10, 10, 10, 10, 10 ],
#                   [ 225, 225, 225, 225, 225 ],
#                   [ 1, 1, 1, 1, 1 ]
#                ],
#                "cooldownBurn": "16/15/14/13/12",
#                "description": "Aatrox takes flight and slams down at a targeted location, dealing damage and knocking up enemies at the center of impact.",
#                "name": "Dark Flight",
#                "sanitizedTooltip": "Aatrox takes flight and slams down at a targeted location, dealing {{ e1 }} (+{{ a1 }}) physical damage to all nearby enemies and knocking up targets at the center of impact for {{ e5 }} second.",
#                "key": "AatroxQ",
#                "costBurn": "0",
#                "tooltip": "Aatrox takes flight and slams down at a targeted location, dealing {{ e1 }}<span class=\"colorF88017\"> (+{{ a1 }})<\/span> physical damage to all nearby enemies and knocking up targets at the center of impact for {{ e5 }} second."
#             },

  def parse_damage_formula(text)
    damage_formula = nil
    my_custom_regex = /(formula\d)(?!formula\d).?([Bb]onus|)\s([Pp]hysical|[mM]agic|[mM]agical|[tT]rue)\s([dD]amage)/
    matched_text = text.match(my_custom_regex)
    unless matched_text.nil? 
      damage_formula =  matched_text.to_a[1].downcase
    end
    damage_formula
  end

  def parse_damage_type(text)
    damage_type = nil
    my_custom_regex = /\{\{\s[efa]\d\s\}\}(?!\{\{\s[efa]\d\s\}\}).?([Bb]onus|)\s([Pp]hysical|[mM]agic|[mM]agical|[tT]rue)\s([dD]amage)/
    matched_text = text.match(my_custom_regex)
    unless matched_text.nil? 
      damage_type =  matched_text.to_a[-2].downcase
      damage_type = 'magic' if damage_type == 'magical'
      # formula = parse_formula(matched_text[0])
    end
    damage_type
  end

  def get_sentences_with_elements(text)
    my_custom_regex = /(([A-Z][^.?!]*?)?(?<!\\w)(?i)(\{\{\s[efa]\d\s\}\})((\%?[\s\-]?[\(]?[\+]?\{\{\s[efa]\d\s\}\})+)?(?!\\w)[^.?!]*?[.?!]{1,2}\"?)/
    text_match = text.scan(my_custom_regex)
    text_match
  end

  # TODO take a look at ruby source and see why scan/split won't work with this regex
  def get_formulas(text)
    elements = []
    my_custom_regex = /(\(?\%?[\s\-]?\(?\+?\{\{\s[efa]\d\s\}\}\)?\%?)+/
    matched_text = text.match(my_custom_regex)
    until matched_text.nil?
      elements << matched_text[0]
      regex_start = text.index(matched_text[0])
      regex_end = regex_start + matched_text[0].length
      text = text[regex_end...text.length]
      matched_text = text.match(my_custom_regex)  
    end
    elements
  end

  def rewrite_tooltip!(text, count)
    elements = get_formulas(text)
    elements.each do |element|
      text.sub!(element, " (formula#{count})")
      count += 1
    end
    text
  end

  def modify_range(unmodified_range)
    #unmodified range is "self" or array of integers
    range = unmodified_range
    range = ['self'] if unmodified_range == 'self'
    range
  end

  def rewrite_resource(text, count)
    resources = text.split(/,|a+n+d+|\//)
    resources.map! do |resource|
      resource.downcase!
      resource = resource.strip unless resource.strip.nil?
      resource.sub!('no cost', 'nocost')
      resource.sub!(/\{\{\scost\s\}\}/, 'resourcecost')
      resource.sub!('% of current health', ' percentcurrenthealth')
      resource.sub!('mana per second', 'mana')
      resource.sub!('mana per attack', 'mana')
      resource.sub!('mana per rocket', 'mana')
      resource.sub!('fury a second','fury')
      resource.sub!('health per sec', 'health')
      resource.sub!(/builds\s\d\sferocity/, 'ferocity')
      resource.sub!('nocost or 50 fury', 'nocostorfifty') # change to fury?
      resource.sub!('initial mana cost per second', 'mana')
      resource.sub!('1 seed', 'seed')
      resource.sub!('essence of shadow', 'essenceofshadow')
      resource_formula = resource.scan(/[efa]\d/)[0]
      unless resource_formula.nil?
        resource.sub!(/\{\{\s[efa]\d\s\}\}/, rewrite_tooltip!(resource, count))
        resource.strip!
        count += 1
      end
      resource
    end
    resources
  end

  # rename text to something more appropriate something plural
  def rewrite_formulas(text)
    formulas = []
    text.each do |formula|
      my_text = formula.scan(/[efa]\d/)
      formulas << my_text.join("+")
    end
    formulas
  end

  def parse_formula(text)
    my_custom_regex = /(\{\{\s[efa]\d\s\}\}.*\}\}|\{\{\s[efa]\d\s\}\})/
    matched_text = text.match(my_custom_regex)
    return matched_text[0]
  end

end
# RiotApiHandler.new().seed_me_seymour_from_api
# RiotApiHandler.new().parse_champion_abilities("/Users/keith/Documents/Programming/Ruby/Workspace/lolwebsite/app/riot_api_responses")

