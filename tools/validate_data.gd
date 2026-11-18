extends SceneTree

const VALIDATOR_SCRIPT: Script = preload("res://scripts/core/data_validator.gd")
const REQUIRED_KEYS: PackedStringArray = [
	"COOP_TITLE", "COOP_SITE", "COOP_OWNED", "COOP_DAY", "COOP_COUNTS", "COOP_STOCK", "COOP_CARE", "COOP_BUNDLE", "COOP_BUY", "COOP_FOOD_QUANTITY", "COOP_HENS_QUANTITY", "COOP_BUY_FEED", "COOP_FEED", "COOP_COLLECT", "COOP_BAG", "COOP_READY", "COOP_PURCHASED", "COOP_FED", "COOP_COLLECTED", "COOP_NO_COINS", "COOP_FULL", "COOP_NO_FEED", "COOP_OCCUPIED", "COOP_CHANGED", "COOP_PROMPT", "COOP_LEDGER", "COOP_FOOD_LEDGER",
	"ITEM_CHICKEN_FEED_NAME", "ITEM_CHICKEN_FEED_DESCRIPTION",
	"ITEM_EGG_NAME", "ITEM_EGG_DESCRIPTION",
	"UI_INVENTORY_TITLE",
	"UI_INVENTORY_EMPTY",
	"UI_HOTBAR_EMPTY",
	"UI_DEBUG_TITLE",
	"UI_DEBUG_SET_0600",
	"UI_DEBUG_SET_1200",
	"UI_DEBUG_SET_2000",
	"UI_DEBUG_SET_2330",
	"UI_DEBUG_ADD_HOUR",
	"UI_DEBUG_NEXT_DAY",
	"UI_DEBUG_PAUSE",
	"UI_DEBUG_SPEED_X1",
	"UI_DEBUG_SPEED_X5",
	"UI_DEBUG_SPEED_X20",
	"UI_DEBUG_MOVE_NEAR_HOME",
	"UI_INV_BUTTON",
	"UI_INV_BUTTON_TOOLTIP",
	"UI_SLEEP_HINT",
	"UI_SLEEP_PENDING",
	"UI_TOOL_HOE",
	"UI_TOOL_WATER",
	"UI_TOOL_SEED",
	"UI_TOOL_HARVEST",
	"UI_DEBUG_HOE_ALL",
	"UI_DEBUG_WATER_ALL",
	"UI_DEBUG_GROW_DAY",
	"UI_DEBUG_RESET_FARM",
	"UI_DEBUG_ADD_SEEDS",
	"UI_DEBUG_CLEAR_INVENTORY"
	,"ITEM_TURNIP_SEED"
	,"ITEM_TURNIP"
	,"ITEM_SPRING_CARROT_SEED"
	,"ITEM_SPRING_CARROT"
	,"ITEM_SPRING_PEA_SEED"
	,"ITEM_SPRING_PEA"
	,"ITEM_SUMMER_TOMATO_SEED"
	,"ITEM_SUMMER_TOMATO"
	,"ITEM_SUMMER_CORN_SEED"
	,"ITEM_SUMMER_CORN"
	,"ITEM_AUTUMN_WHEAT_SEED"
	,"ITEM_AUTUMN_WHEAT"
	,"ITEM_AUTUMN_PUMPKIN_SEED"
	,"ITEM_AUTUMN_PUMPKIN"
	,"ITEM_WINTER_RADISH_SEED"
	,"ITEM_WINTER_RADISH"
	,"ITEM_WINTER_CABBAGE_SEED"
	,"ITEM_WINTER_CABBAGE"
	,"CROP_TURNIP"
	,"UI_CLOCK_DAY_TIME"
	,"UI_TIME_DAWN"
	,"UI_TIME_MORNING"
	,"UI_TIME_AFTERNOON"
	,"UI_TIME_DUSK"
	,"UI_TIME_NIGHT"
	,"UI_WEATHER_CURRENT"
	,"WEATHER_SUNNY"
	,"WEATHER_CLOUDY"
	,"WEATHER_RAIN"
	,"WEATHER_STORM"
	,"UI_DEBUG_WEATHER_SUNNY"
	,"UI_DEBUG_WEATHER_RAIN"
	,"UI_DEBUG_WEATHER_STORM"
	,"UI_WALLET_COINS"
	,"UI_PROMPT_SELL"
	,"UI_SHIPPING_BIN_TITLE"
	,"UI_CONFIRM_SELL"
	,"UI_NO_SELLABLE_ITEMS"
	,"UI_MAX"
	,"UI_PROMPT_SHOP"
	,"UI_SEED_SHOP_TITLE"
	,"UI_BUY_PRICE"
	,"UI_CONFIRM_BUY"
	,"UI_FEEDBACK_BOUGHT"
	,"UI_FEEDBACK_NOT_ENOUGH_COINS"
	,"UI_FEEDBACK_INVENTORY_FULL"
	,"UI_SEASON_NOTE"
	,"UI_QUEST_SELL"
	,"UI_QUEST_BUY_SEED"
	,"UI_DEBUG_ADD_COINS"
	,"UI_DEBUG_ADD_ALL_SEEDS"
	,"QUEST_TURNIP_DELIVERY_TITLE"
	,"QUEST_TURNIP_DELIVERY_DESC"
	,"UI_QUEST_DELIVERY_TITLE"
	,"UI_QUEST_REQUIREMENT"
	,"UI_QUEST_REWARD"
	,"UI_CONFIRM_DELIVERY"
	,"UI_FEEDBACK_QUEST_COMPLETED"
	,"UI_FEEDBACK_NOT_ENOUGH_ITEMS"
	,"UI_NPC_CLOSE", "UI_NPC_TALK_HINT", "UI_NPC_HOME", "UI_NPC_JOURNAL", "UI_NPC_JOURNAL_HINT"
	,"UI_NPC_FRIENDSHIP", "UI_NPC_QUEST_NEW", "UI_NPC_QUEST_ACTIVE", "UI_NPC_QUEST_DONE", "UI_NPC_ACCEPT_QUEST"
	,"UI_NPC_OFFER_DISCOUNT", "UI_NPC_OFFER_REQUEST", "UI_NPC_CONFIRM_TRADE", "UI_NPC_TRADE_DONE", "UI_NPC_TRADE_BLOCKED"
	,"UI_DEBUG_NPC_VISIT", "UI_DEBUG_NPC_ITEMS", "UI_DEBUG_NPC_JOURNAL"
	,"UI_NPC_DELIVERY_BLOCKED"
	,"UI_BACK", "UI_APPEARANCE_HAIR_STYLE", "UI_APPEARANCE_SKIN_TONE", "UI_APPEARANCE_HAIR_COLOR", "UI_APPEARANCE_OUTFIT_COLOR", "UI_APPEARANCE_OPTION_NUMBER"
	,"UI_APPEARANCE_HAIR_ROUND_BOB", "UI_APPEARANCE_HAIR_SOFT_BANGS", "UI_APPEARANCE_HAIR_LEAF_BRAID", "UI_APPEARANCE_HAIR_SIDE_SWOOP", "UI_APPEARANCE_HAIR_SHORT_PEAK", "UI_APPEARANCE_HAIR_TWIN_PUFFS"
	,"NPC_AN_NAME", "NPC_LAM_NAME", "PET_DOG_NAME"
	,"WATER_SOURCE_WELL", "WATER_CAN_COUNT", "WATER_CAN_EMPTY", "WATER_REFILL_HINT", "WATER_REFILLED", "WATER_CAN_FULL", "WATER_REFILL_UNAVAILABLE", "WATER_SOURCE_STREAM", "WATER_SOURCE_POND"
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var item_paths: Array[String] = [
		"res://data/items/turnip_seed.tres",
		"res://data/items/turnip.tres",
		"res://data/items/spring_carrot_seed.tres",
		"res://data/items/spring_carrot.tres",
		"res://data/items/spring_pea_seed.tres",
		"res://data/items/spring_pea.tres",
		"res://data/items/summer_tomato_seed.tres",
		"res://data/items/summer_tomato.tres",
		"res://data/items/summer_corn_seed.tres",
		"res://data/items/summer_corn.tres",
		"res://data/items/autumn_wheat_seed.tres",
		"res://data/items/autumn_wheat.tres",
		"res://data/items/autumn_pumpkin_seed.tres",
		"res://data/items/autumn_pumpkin.tres",
		"res://data/items/winter_radish_seed.tres",
		"res://data/items/winter_radish.tres",
		"res://data/items/winter_cabbage_seed.tres",
		"res://data/items/winter_cabbage.tres"
	]
	# Keep the complete historical C2 art set; egg/feed use the approved generic fallback.
	var visual_item_paths: Array[String] = item_paths.duplicate()
	item_paths.append("res://data/items/egg.tres")
	item_paths.append("res://data/items/chicken_feed.tres")
	var crop_paths: Array[String] = [
		"res://data/crops/turnip.tres",
		"res://data/crops/spring_carrot.tres",
		"res://data/crops/spring_pea.tres",
		"res://data/crops/summer_tomato.tres",
		"res://data/crops/summer_corn.tres",
		"res://data/crops/autumn_pumpkin.tres",
		"res://data/crops/autumn_wheat.tres",
		"res://data/crops/winter_cabbage.tres",
		"res://data/crops/winter_radish.tres"
	]
	var quest_paths: Array[String] = [
		"res://data/quests/quest_turnip_delivery.tres"
	]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_paths(item_paths)
	errors.append_array((preload("res://data/chicken_coop_site.tres") as ChickenCoopSiteConfig).validation_errors())
	if errors.is_empty():
		var coop_config: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
		errors = coop_config.validation_errors()
		if errors.is_empty():
			var known_feed: bool = false
			for item_path: String in item_paths:
				var item: ItemData = load(item_path) as ItemData
				if item!=null and item.item_id==coop_config.feed_item_id:
					known_feed = true
					break
			if not known_feed:
				errors.append("chicken coop feed is not in the logical item registry")
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_inventory_config(preload("res://data/inventory_config.tres"))
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_isometric_world_config(preload("res://data/isometric_world_config.tres"))
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_isometric_2d_assets()
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_machine_build_config(preload("res://data/machine_build_config.tres"), preload("res://data/isometric_world_config.tres"))
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_watering_can_config(preload("res://data/watering_can_config.tres"))
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_bag_upgrade_config(preload("res://data/bag_upgrade_config.tres"))
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_land_expansion_config(preload("res://data/land_expansion_config.tres"))
	if errors.is_empty():
		errors = VALIDATOR_SCRIPT.validate_water_source_config(preload("res://data/water_sources.tres"),(preload("res://data/npcs/phase8_world.tres") as NpcWorldData).locations,preload("res://data/land_expansion_config.tres"))
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_item_paths(crop_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_crop_paths(crop_paths, item_paths)
	if errors.is_empty():
		var economy_crops: Array[Resource] = []
		var economy_items: Array[Resource] = []
		for path: String in crop_paths:
			economy_crops.append(load(path) as Resource)
		for path: String in item_paths:
			economy_items.append(load(path) as Resource)
		errors = VALIDATOR_SCRIPT.validate_crop_economy(preload("res://data/crop_economy_config.tres"), economy_crops, economy_items)
		if errors.is_empty():
			errors = VALIDATOR_SCRIPT.validate_crop_migration(preload("res://data/crop_migration_v7.tres"), economy_crops)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_quest_paths(quest_paths, item_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_weather_profile("res://data/weather_profile.tres")
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_art_palette_path("res://data/art/palette/chibi_valley.tres")
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_character_catalog_path("res://data/art/characters/chibi_character_catalog.tres")
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_farming_art_catalog_path("res://data/art/farming/chibi_farming_catalog.tres")
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_world_art_catalog_path("res://data/art/world/chibi_world_catalog.tres")
	if errors.size() == 0:
		var visual_items: Array[Resource] = []
		for item_path: String in visual_item_paths:
			visual_items.append(load(item_path) as Resource)
		errors = VALIDATOR_SCRIPT.validate_item_visual_assets(visual_items)
	if errors.size() > 0:
		for error_message: String in errors:
			push_error(error_message)
		quit(1)
		return
	var locale_paths: Array[String] = [
		"res://localization/strings_vi.csv",
		"res://localization/strings_en.csv"
	]
	var inventory_keys: PackedStringArray = REQUIRED_KEYS.duplicate()
	inventory_keys.append_array(PackedStringArray(["PLC_PLACE","PLC_RETURN","PLC_RETURNED","PLC_TITLE","PLC_CELL","PLC_PICK","PLC_VALID","PLC_HINTS","PLC_LEFT","PLC_RIGHT","PLC_CANCEL","PLC_CONFIRM","PLC_REGION","PLC_PLAYER","PLC_FAR","PLC_PLOT","PLC_MACHINE_CELL","PLC_INVALID"]))
	inventory_keys.append_array(PackedStringArray(["LAND_TITLE", "LAND_EAST_NAME", "LAND_DESCRIPTION", "LAND_OWNED", "LAND_EXTRA", "LAND_PRICE", "LAND_WALLET", "LAND_BUY", "LAND_AVAILABLE", "LAND_COMPLETE", "LAND_NO_COINS", "LAND_PURCHASED", "LAND_BUSY", "LAND_STALE", "LAND_REJECTED", "LAND_INVALID", "LAND_LOCKED", "LAND_PLACEMENT", "LAND_LEDGER"]))
	inventory_keys.append_array(PackedStringArray(["WATER_UP_ACTION", "WATER_UP_TITLE", "WATER_UP_DESCRIPTION", "WATER_UP_CAPACITY", "WATER_UP_PRICE", "WATER_UP_WALLET", "WATER_UP_BACK", "WATER_UP_CONFIRM", "WATER_UP_AVAILABLE", "WATER_UP_SUCCESS", "WATER_UP_COMPLETE", "WATER_UP_NO_COINS", "WATER_UP_STALE", "WATER_UP_BUSY", "WATER_UP_REFUND", "WATER_UP_INVALID", "WATER_UP_LEDGER", "WATER_UP_REMAINING"]))
	inventory_keys.append_array(PackedStringArray(["BAG_UP_ACTION", "BAG_UP_TITLE", "BAG_UP_DESCRIPTION", "BAG_UP_CAPACITY", "BAG_UP_PRICE", "BAG_UP_WALLET", "BAG_UP_BACK", "BAG_UP_CONFIRM", "BAG_UP_AVAILABLE", "BAG_UP_SUCCESS", "BAG_UP_COMPLETE", "BAG_UP_NO_COINS", "BAG_UP_STALE", "BAG_UP_BUSY", "BAG_UP_REFUND", "BAG_UP_INVALID", "BAG_UP_LEDGER"]))
	inventory_keys.append("UI_CROP_REGROW_NOTE")
	inventory_keys.append_array(PackedStringArray(["PLC_MOVE","PLC_MOVE_TITLE","PLC_MOVE_CELL","PLC_MOVE_PICK","PLC_MOVE_VALID","PLC_MOVE_HINTS","PLC_MOVE_CONFIRM","PLC_MOVE_CANCEL","PLC_MOVED","PLC_ROTATED","PLC_MOVE_STALE"]))
	for item_path: String in item_paths:
		var item: ItemData = load(item_path) as ItemData
		if not item.description_key.is_empty():
			inventory_keys.append(String(item.description_key))
	errors = VALIDATOR_SCRIPT.validate_translation_keys(locale_paths, inventory_keys)
	if errors.is_empty():
		var items: Array[Resource] = []
		for item_path: String in item_paths:
			items.append(load(item_path))
		var quests: Array[Resource] = []
		for quest_path: String in quest_paths:
			quests.append(load(quest_path))
		errors = VALIDATOR_SCRIPT.validate_npc_world(preload("res://data/npcs/phase8_world.tres"), items, quests, locale_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_vietnamese_values(
			"res://localization/strings_en.csv",
			"res://localization/strings_vi.csv"
		)
	if errors.size() > 0:
		for error_message: String in errors:
			push_error(error_message)
		quit(1)
		return
	var registry: Node = root.get_node_or_null("DataRegistry")
	if registry==null:
		push_error("recipe validation registry unavailable")
		quit(1)
		return
	var recipe_errors: PackedStringArray = VALIDATOR_SCRIPT.validate_recipe_economy(preload("res://data/recipe_economy_config.tres"),registry.call("get_all_recipes"),registry.call("get_all_machines"),registry.call("get_all_items"))
	if not recipe_errors.is_empty():
		for message: String in recipe_errors:
			push_error(message)
		quit(1)
		return
	var stage_errors: PackedStringArray = VALIDATOR_SCRIPT.validate_crop_stage_config(preload("res://data/crop_stage_config.tres"))
	if not stage_errors.is_empty():
		for message: String in stage_errors:
			push_error(message)
		quit(1)
		return
	var scenery_errors: PackedStringArray = VALIDATOR_SCRIPT.validate_scenery_catalog(preload("res://data/art/world/isometric_scenery_catalog.tres"))
	if not scenery_errors.is_empty():
		for message: String in scenery_errors:
			push_error(message)
		quit(1)
		return
	var ecology_errors: PackedStringArray = VALIDATOR_SCRIPT.validate_ecology_profile(preload("res://data/ecology_profile.tres"))
	if not ecology_errors.is_empty():
		for message: String in ecology_errors:
			push_error(message)
		quit(1)
		return
	print("[validate_data] PASS")
	quit(0)
