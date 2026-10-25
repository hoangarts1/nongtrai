extends SceneTree

const VALIDATOR_SCRIPT: Script = preload("res://scripts/core/data_validator.gd")

func _init() -> void:
	var item_paths: Array[String] = [
		"res://data/items/turnip_seed.tres",
		"res://data/items/turnip.tres"
	]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_paths(item_paths)
	if errors.size() > 0:
		for error_message: String in errors:
			push_error(error_message)
		quit(1)
		return
	print("[validate_data] PASS")
	quit(0)
