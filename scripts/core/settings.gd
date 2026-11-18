## Settings — persistent player preferences.
## API: get_preferences()->Dictionary; apply_preferences(patch:Dictionary)->Dictionary.
## Existing void getters/setters remain compatible; settings never enter world saves.
extends Node

signal preferences_changed(values: Dictionary)
const SETTINGS_PATH: String = "user://settings.cfg"
const SETTINGS_SECTION: String = "ui"
const TUTORIAL_KEY: String = "tutorial_dismissed"
const LOCALE_KEY: String = "locale"
const MUSIC_VOLUME_KEY: String = "music_volume"
const EFFECTS_VOLUME_KEY: String = "effects_volume"
var _config: ConfigFile = ConfigFile.new()
var file_store: SettingsFileStore = SettingsFileStore.new()
var _applying: bool = false

func _ready() -> void:
	if _config.load(SETTINGS_PATH) != OK:
		_config = ConfigFile.new()
	# Normalize accepted memory only; malformed user files are not rewritten on read.
	var normalized: Dictionary = get_preferences()
	for key: String in normalized:
		_config.set_value(SETTINGS_SECTION, key, normalized[key])
	TranslationServer.set_locale(String(normalized.locale))

func get_preferences() -> Dictionary:
	var raw: Dictionary = {}
	var defaults: Dictionary = SettingsCodec.defaults()
	for key: String in defaults:
		raw[key] = _config.get_value(SETTINGS_SECTION, key, defaults[key])
	return SettingsCodec.decode(raw).values

func apply_preferences(patch: Dictionary) -> Dictionary:
	if _applying:
		return {"ok": false, "error": &"busy"}
	var before: Dictionary = get_preferences()
	var merged: Dictionary = before.duplicate(true)
	var locale_requested: bool = false
	for key: Variant in patch:
		if not key is String and not key is StringName:
			return {"ok": false, "error": &"invalid_preferences"}
		if not merged.has(String(key)):
			return {"ok": false, "error": &"invalid_preferences"}
		merged[String(key)] = patch[key]
		locale_requested = locale_requested or String(key) == LOCALE_KEY
	var decoded: Dictionary = SettingsCodec.decode(merged, true)
	if not decoded.ok:
		return {"ok": false, "error": &"invalid_preferences"}
	var candidate: ConfigFile = ConfigFile.new()
	if candidate.parse(_config.encode_to_text()) != OK:
		return {"ok": false, "error": &"invalid_config"}
	for key: String in decoded.values:
		candidate.set_value(SETTINGS_SECTION, key, decoded.values[key])
	_applying = true
	var persisted: Dictionary = file_store.persist(SETTINGS_PATH, candidate.encode_to_text())
	if not persisted.ok:
		_applying = false
		return {"ok": false, "error": &"persist_failed", "write_report": persisted}
	_config = candidate
	if locale_requested:
		TranslationServer.set_locale(String(decoded.values.locale))
	if decoded.values != before:
		preferences_changed.emit(decoded.values.duplicate(true))
	_applying = false
	return {"ok": true, "error": &"", "values": decoded.values.duplicate(true), "write_report": persisted}

func is_tutorial_dismissed() -> bool:
	return bool(get_preferences()[TUTORIAL_KEY])

func set_tutorial_dismissed(dismissed: bool) -> void:
	_apply_legacy({TUTORIAL_KEY: dismissed})

func get_locale() -> String:
	return String(get_preferences()[LOCALE_KEY])

func set_locale(locale: String) -> void:
	_apply_legacy({LOCALE_KEY: locale})

func get_music_volume() -> float:
	return float(get_preferences()[MUSIC_VOLUME_KEY])

func set_music_volume(volume: float) -> void:
	_apply_legacy({MUSIC_VOLUME_KEY: clampf(volume, 0.0, 1.0) if is_finite(volume) else volume})

func get_effects_volume() -> float:
	return float(get_preferences()[EFFECTS_VOLUME_KEY])

func set_effects_volume(volume: float) -> void:
	_apply_legacy({EFFECTS_VOLUME_KEY: clampf(volume, 0.0, 1.0) if is_finite(volume) else volume})

func _apply_legacy(patch: Dictionary) -> void:
	var result: Dictionary = apply_preferences(patch)
	if not result.ok:
		push_warning("Settings: preference update rejected (%s)" % result.error)
