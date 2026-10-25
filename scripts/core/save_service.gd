## SaveService — validates, migrates and atomically stores JSON save payloads.
## API:
##   func save_game(payload: Dictionary, slot: int = 1) -> bool
##   func load_game(slot: int = 1) -> Dictionary
##   func delete_save(slot: int = 1) -> void
extends Node

const CURRENT_VERSION: int = 1
const SAVE_DIRECTORY: String = "user://saves"
const MAX_BACKUPS: int = 3

func save_game(payload: Dictionary, slot: int = 1) -> bool:
	if slot < 0:
		return false
	var wrapped: Dictionary = {
		"meta": {
			"save_version": CURRENT_VERSION,
			"game_version": "0.1.0",
			"saved_utc": Time.get_unix_time_from_system()
		},
		"clock": payload.get("clock", {}),
		"player": payload.get("player", {}),
		"inventory": payload.get("inventory", {}),
		"farm": payload.get("farm", {})
	}
	var directory_path: String = ProjectSettings.globalize_path(SAVE_DIRECTORY)
	if DirAccess.make_dir_recursive_absolute(directory_path) != OK:
		push_error("SaveService: could not create save directory")
		return false
	var save_path: String = _save_path(slot)
	var temporary_path: String = "%s.tmp" % save_path
	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveService: could not open temporary save")
		return false
	file.store_string(JSON.stringify(wrapped, "\t"))
	file.close()
	_rotate_backups(save_path)
	if DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(save_path)
	) != OK:
		push_error("SaveService: could not replace save file")
		return false
	return true

func load_game(slot: int = 1) -> Dictionary:
	if slot < 0:
		return {}
	var file: FileAccess = FileAccess.open(_save_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = parsed
	var version: int = int((data.get("meta", {}) as Dictionary).get("save_version", 0))
	if version > CURRENT_VERSION:
		return {}
	return _migrate(data, version)

func delete_save(slot: int = 1) -> void:
	if slot < 0:
		return
	var path: String = _save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _migrate(data: Dictionary, version: int) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	if version == 0:
		migrated["meta"] = {"save_version": CURRENT_VERSION}
	return migrated

func _save_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIRECTORY, slot]

func _rotate_backups(save_path: String) -> void:
	for index: int in range(MAX_BACKUPS, 0, -1):
		var source: String = "%s.bak%d" % [save_path, index - 1] if index > 1 else save_path
		var target: String = "%s.bak%d" % [save_path, index]
		if FileAccess.file_exists(source):
			if FileAccess.file_exists(target):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(source),
				ProjectSettings.globalize_path(target)
			)
