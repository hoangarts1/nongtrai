## Localization — runtime translation registry for the player-facing UI.
extends Node

const CSV_PATHS: Dictionary = {
	"vi": "res://localization/strings_vi.csv",
	"en": "res://localization/strings_en.csv",
}

var _loaded: bool = false

func _ready() -> void:
	_load_translations()
	apply_default_locale()

func apply_default_locale() -> void:
	TranslationServer.set_locale("vi")

func load_translations() -> bool:
	if _loaded:
		return true
	_loaded = _load_translations()
	return _loaded

func _load_translations() -> bool:
	var all_loaded: bool = true
	for locale: String in CSV_PATHS.keys():
		var translation: Translation = _read_translation(locale)
		if translation == null:
			all_loaded = false
			continue
		TranslationServer.add_translation(translation)
	return all_loaded

func _read_translation(locale: String) -> Translation:
	if not CSV_PATHS.has(locale):
		return null
	var path: String = CSV_PATHS[locale]
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var translation: Translation = Translation.new()
	translation.locale = locale
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.strip_edges().is_empty() or line.begins_with("#"):
			continue
		var cells: PackedStringArray = _parse_csv_line(line)
		if cells.size() < 2:
			continue
		var key: String = cells[0].strip_edges()
		var value: String = cells[1].strip_edges()
		if key.is_empty():
			continue
		translation.add_message(key, value)
	return translation

func _parse_csv_line(line: String) -> PackedStringArray:
	var values: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	for index: int in range(line.length()):
		var character: String = line.substr(index, 1)
		if character == "\"":
			if in_quotes and index + 1 < line.length() and line.substr(index + 1, 1) == "\"":
				current += "\""
				index += 1
			else:
				in_quotes = not in_quotes
		elif character == "," and not in_quotes:
			values.append(current)
			current = ""
		else:
			current += character
	values.append(current)
	return values
