# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150313044537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abilities", force: :cascade do |t|
    t.text     "champion_key"
    t.text     "ability_id"
    t.text     "name"
    t.text     "description"
    t.text     "tooltip"
    t.text     "leveltip_label",  default: [],              array: true
    t.text     "leveltip_effect", default: [],              array: true
    t.integer  "maxrank"
    t.integer  "cooldown",        default: [],              array: true
    t.text     "cooldownBurn"
    t.integer  "cost",            default: [],              array: true
    t.text     "costBurn"
    t.integer  "effect"
    t.text     "effectBurn",      default: [],              array: true
    t.text     "costType"
    t.integer  "range",           default: [],              array: true
    t.text     "rangeBurn"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "abilities", ["champion_key"], name: "index_abilities_on_champion_key", using: :btree

  create_table "champions", force: :cascade do |t|
    t.integer  "champion_id"
    t.text     "key"
    t.text     "name"
    t.text     "title"
    t.text     "lore"
    t.text     "blurb"
    t.text     "allytips",               default: [],              array: true
    t.text     "enemytips",              default: [],              array: true
    t.text     "tags",                   default: [],              array: true
    t.text     "resource_type"
    t.float    "hp"
    t.float    "hp_per_level"
    t.float    "mp"
    t.float    "mp_per_level"
    t.float    "movespeed"
    t.float    "armor"
    t.float    "armor_per_level"
    t.float    "spellblock"
    t.float    "spellblock_per_level"
    t.float    "attackrange"
    t.float    "hpregen"
    t.float    "hpregen_per_level"
    t.float    "mpregen"
    t.float    "mpregen_per_level"
    t.float    "crit"
    t.float    "crit_per_level"
    t.float    "attackdamage"
    t.float    "attackdamage_per_level"
    t.float    "attackspeedoffset"
    t.float    "attackspeed_per_level"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "champions", ["champion_id"], name: "index_champions_on_champion_id", using: :btree
  add_index "champions", ["key"], name: "index_champions_on_key", using: :btree
  add_index "champions", ["name"], name: "index_champions_on_name", using: :btree

  create_table "coefficients", force: :cascade do |t|
    t.text     "link"
    t.integer  "ability_id"
    t.float    "coeff"
    t.text     "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "coefficients", ["ability_id"], name: "index_coefficients_on_ability_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.text     "full"
    t.text     "sprite"
    t.text     "group"
    t.integer  "x"
    t.integer  "y"
    t.integer  "w"
    t.integer  "h"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "images", ["full"], name: "index_images_on_full", using: :btree
  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.text     "name"
    t.text     "item_id"
    t.text     "sanitizedDescription"
    t.text     "tags",                                default: [], array: true
    t.text     "requiredChampion"
    t.integer  "total_gold"
    t.text     "group"
    t.float    "FlatHPPoolMod"
    t.float    "rFlatHPModPerLevel"
    t.float    "FlatMPPoolMod"
    t.float    "rFlatMPModPerLevel"
    t.float    "PercentHPPoolMod"
    t.float    "PercentMPPoolMod"
    t.float    "FlatHPRegenMod"
    t.float    "rFlatHPRegenModPerLevel"
    t.float    "PercentHPRegenMod"
    t.float    "FlatMPRegenMod"
    t.float    "rFlatMPRegenModPerLevel"
    t.float    "PercentMPRegenMod"
    t.float    "FlatArmorMod"
    t.float    "rFlatArmorModPerLevel"
    t.float    "PercentArmorMod"
    t.float    "rFlatArmorPenetrationMod"
    t.float    "rFlatArmorPenetrationModPerLevel"
    t.float    "rPercentArmorPenetrationMod"
    t.float    "rPercentArmorPenetrationModPerLevel"
    t.float    "FlatPhysicalDamageMod"
    t.float    "rFlatPhysicalDamageModPerLevel"
    t.float    "PercentPhysicalDamageMod"
    t.float    "FlatMagicDamageMod"
    t.float    "rFlatMagicDamageModPerLevel"
    t.float    "PercentMagicDamageMod"
    t.float    "FlatMovementSpeedMod"
    t.float    "rFlatMovementSpeedModPerLevel"
    t.float    "PercentMovementSpeedMod"
    t.float    "rPercentMovementSpeedModPerLevel"
    t.float    "FlatAttackSpeedMod"
    t.float    "PercentAttackSpeedMod"
    t.float    "rPercentAttackSpeedModPerLevel"
    t.float    "rFlatDodgeMod"
    t.float    "rFlatDodgeModPerLevel"
    t.float    "PercentDodgeMod"
    t.float    "FlatCritChanceMod"
    t.float    "rFlatCritChanceModPerLevel"
    t.float    "PercentCritChanceMod"
    t.float    "FlatCritDamageMod"
    t.float    "rFlatCritDamageModPerLevel"
    t.float    "PercentCritDamageMod"
    t.float    "FlatBlockMod"
    t.float    "PercentBlockMod"
    t.float    "FlatSpellBlockMod"
    t.float    "rFlatSpellBlockModPerLevel"
    t.float    "PercentSpellBlockMod"
    t.float    "FlatEXPBonus"
    t.float    "PercentEXPBonus"
    t.float    "rPercentCooldownMod"
    t.float    "rPercentCooldownModPerLevel"
    t.float    "rFlatTimeDeadMod"
    t.float    "rFlatTimeDeadModPerLevel"
    t.float    "rPercentTimeDeadMod"
    t.float    "rPercentTimeDeadModPerLevel"
    t.float    "rFlatGoldPer10Mod"
    t.float    "rFlatMagicPenetrationMod"
    t.float    "rFlatMagicPenetrationModPerLevel"
    t.float    "rPercentMagicPenetrationMod"
    t.float    "rPercentMagicPenetrationModPerLevel"
    t.float    "FlatEnergyRegenMod"
    t.float    "rFlatEnergyRegenModPerLevel"
    t.float    "FlatEnergyPoolMod"
    t.float    "rFlatEnergyModPerLevel"
    t.float    "PercentLifeStealMod"
    t.float    "PercentSpellVampMod"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["item_id"], name: "index_items_on_item_id", using: :btree
  add_index "items", ["name"], name: "index_items_on_name", using: :btree

  create_table "passives", force: :cascade do |t|
    t.text     "champion_key"
    t.text     "name"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "passives", ["champion_key"], name: "index_passives_on_champion_key", using: :btree

  create_table "skins", force: :cascade do |t|
    t.text     "champion_key"
    t.integer  "skin_id"
    t.integer  "num"
    t.text     "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "skins", ["champion_key"], name: "index_skins_on_champion_key", using: :btree

  create_table "splashes", force: :cascade do |t|
    t.integer  "champion_id"
    t.text     "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "splashes", ["champion_id"], name: "index_splashes_on_champion_id", using: :btree

end
