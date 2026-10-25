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
	"UI_TOOL_SEED"
]

func _init() -> void:
	var item_paths: Array[String] = [
		"res://data/items/turnip_seed.tres",
		"res://data/items/turnip.tres"
	]
	var crop_paths: Array[String] = [
		"res://data/crops/turnip.tres"
	]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_paths(item_paths)
	if errors.size() == 0:
		errors = VALIDATOR_SCRIPT.validate_item_paths(crop_paths)
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
	if errors.size() > 0:
		for error_message: String in errors:
			push_error(error_message)
		quit(1)
		return
	print("[validate_data] PASS")
	quit(0)
