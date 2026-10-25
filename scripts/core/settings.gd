## Settings — persistent player preferences.
extends Node

const SETTINGS_PATH: String = "user://settings.cfg"
const SETTINGS_SECTION: String = "ui"
const TUTORIAL_KEY: String = "tutorial_dismissed"
const LOCALE_KEY: String = "locale"
const MUSIC_VOLUME_KEY: String = "music_volume"
const EFFECTS_VOLUME_KEY: String = "effects_volume"
var _config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	_config.load(SETTINGS_PATH)

func is_tutorial_dismissed() -> bool:
	return bool(_config.get_value(SETTINGS_SECTION, TUTORIAL_KEY, false))

func set_tutorial_dismissed(dismissed: bool) -> void:
	_config.set_value(SETTINGS_SECTION, TUTORIAL_KEY, dismissed)
	_config.save(SETTINGS_PATH)

func get_locale() -> String:
	return String(_config.get_value(SETTINGS_SECTION, LOCALE_KEY, "vi"))

func set_locale(locale: String) -> void:
	_config.set_value(SETTINGS_SECTION, LOCALE_KEY, locale)
	_config.save(SETTINGS_PATH)
	TranslationServer.set_locale(locale)

func get_music_volume() -> float:
	return float(_config.get_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, 1.0))

func set_music_volume(volume: float) -> void:
	_config.set_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, clampf(volume, 0.0, 1.0))
	_config.save(SETTINGS_PATH)

func get_effects_volume() -> float:
	return float(_config.get_value(SETTINGS_SECTION, EFFECTS_VOLUME_KEY, 1.0))

func set_effects_volume(volume: float) -> void:
	_config.set_value(SETTINGS_SECTION, EFFECTS_VOLUME_KEY, clampf(volume, 0.0, 1.0))
	_config.save(SETTINGS_PATH)
