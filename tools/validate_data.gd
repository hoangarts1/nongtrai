extends SceneTree

const VALIDATOR_SCRIPT: Script = preload("res://scripts/core/data_validator.gd")
const REQUIRED_KEYS: PackedStringArray = [
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
]

func _init() -> void:
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
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_item_paths(crop_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_crop_paths(crop_paths, item_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_quest_paths(quest_paths, item_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_weather_profile("res://data/weather_profile.tres")
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_art_palette_path("res://data/art/palette/chibi_valley.tres")
	if errors.size() > 0:
		for error_message: String in errors:
			push_error(error_message)
		quit(1)
		return
	var locale_paths: Array[String] = [
		"res://localization/strings_vi.csv",
		"res://localization/strings_en.csv"
	]
	errors = VALIDATOR_SCRIPT.validate_translation_keys(locale_paths, REQUIRED_KEYS)
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
	print("[validate_data] PASS")
	quit(0)
