## Settings — persistent player preferences.
extends Node

const SETTINGS_PATH: String = "user://settings.cfg"
const SETTINGS_SECTION: String = "ui"
const TUTORIAL_KEY: String = "tutorial_dismissed"
var _config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	_config.load(SETTINGS_PATH)

func is_tutorial_dismissed() -> bool:
	return bool(_config.get_value(SETTINGS_SECTION, TUTORIAL_KEY, false))

func set_tutorial_dismissed(dismissed: bool) -> void:
	_config.set_value(SETTINGS_SECTION, TUTORIAL_KEY, dismissed)
	_config.save(SETTINGS_PATH)
