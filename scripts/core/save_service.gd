## SaveService — validates, migrates and atomically stores JSON save payloads.
## API:
##   func save_game(payload: Dictionary, slot: int = 1) -> bool
##   func load_game(slot: int = 1) -> Dictionary
##   func delete_save(slot: int = 1) -> void
##   func migrate_5_to_6(data: Dictionary) -> Dictionary
##   func migrate_6_to_7(data: Dictionary) -> Dictionary
##   func migrate_7_to_8(data: Dictionary) -> Dictionary
##   func migrate_8_to_9(data: Dictionary) -> Dictionary
##   func migrate_9_to_10(data: Dictionary) -> Dictionary
##   func migrate_10_to_11(data: Dictionary) -> Dictionary
##   func migrate_11_to_12(data: Dictionary) -> Dictionary
extends Node

const CURRENT_VERSION: int = 12
const WEATHER_CONFIG: WeatherProfile = preload("res://data/weather_profile.tres")
const WATERING_INTRODUCED_VERSION: int = 10
const COOP_CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const WATERING_CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const SAVE_DIRECTORY: String = "user://saves"
const MAX_BACKUPS: int = 3

func save_game(payload: Dictionary, slot: int = 1) -> bool:
	if slot < 0:
		return false
	var wrapped: Dictionary = {
		"meta": {
			"save_version": CURRENT_VERSION,
			"game_version": "0.1.0",
			"saved_utc": Time.get_unix_time_from_system(),
			"saved_at": Time.get_datetime_string_from_system()
		},
		"clock": payload.get("clock", {}),
		"player": payload.get("player", {}),
		"inventory": payload.get("inventory", {}),
		"machine_inventory": payload.get("machine_inventory", {}),
		"machine_placements": payload.get("machine_placements", {}),
		"machine_operations": payload.get("machine_operations", {}),
		"land_ownership": payload.get("land_ownership", {}),
		"watering_can": payload.get("watering_can", {}),
		"chicken_coop": payload.get("chicken_coop", ChickenCoopSaveCodec.empty(_coop_day(payload))),
		"farm": payload.get("farm", {}),
		"quests": payload.get("quests", {}),
		"profile": payload.get("profile", {}),
		"weather": WeatherSaveCodec.pack(WEATHER_CONFIG,payload.get("weather",{}),_coop_day(payload)),
		"wallet": payload.get("wallet", {}),
		"social": payload.get("social", {}),
		"day_ledger": payload.get("day_ledger", {}),
		"day_end": payload.get("day_end", {})
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
	var raw_meta: Variant = data.get("meta", {})
	if not raw_meta is Dictionary:
		return {}
	var raw_version: Variant = raw_meta.get("save_version", 0)
	if not raw_version is int and not raw_version is float:
		return {}
	var version: int = int(raw_version)
	if version < 0:
		return {}
	if version > CURRENT_VERSION:
		return {}
	return _migrate(data, version)

func has_save(slot: int = 1) -> bool:
	return not load_game(slot).is_empty()

func load_latest() -> Dictionary:
	var latest: Dictionary = {}
	var latest_time: float = -1.0
	var latest_day: int = -1
	for slot: int in [0, 1]:
		var payload: Dictionary = load_game(slot)
		if payload.is_empty():
			continue
		var metadata: Dictionary = payload.get("meta", {})
		var raw_utc: Variant = metadata.get("saved_utc",0)
		var saved_utc: float = float(raw_utc) if (raw_utc is int or raw_utc is float) and is_finite(float(raw_utc)) else 0.0
		if not metadata.has("saved_utc"):
			saved_utc = int(metadata.get("saved_at", "0").hash())
		var raw_clock: Variant = payload.get("clock",{})
		var day: int = DayLedgerState.number(raw_clock.get("day_index",0)) if raw_clock is Dictionary else 0
		# Keep subsecond precision; a completed morning wins an exact timestamp tie
		# with the preceding review. Otherwise Continue can replay the old night.
		if saved_utc > latest_time or (saved_utc == latest_time and day >= latest_day):
			latest_time = saved_utc
			latest_day = day
			latest = payload
	return latest

func get_latest_summary() -> Dictionary:
	var payload: Dictionary = load_latest()
	if payload.is_empty():
		return {}
	var metadata: Dictionary = payload.get("meta", {})
	var profile: Dictionary = payload.get("profile", {})
	var clock: Dictionary = payload.get("clock", {})
	return {
		"farm_name": String(profile.get("farm_name", "")),
		"day_index": int(clock.get("day_index", 0)) + 1,
		"saved_at": String(metadata.get("saved_at", "")),
		"saved_utc": int(metadata.get("saved_utc", 0))
	}

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
	if version <= 1:
		migrated["weather"] = migrated.get("weather", {})
	if version <= 2:
		migrated["wallet"] = migrated.get("wallet", {"coins": 100})
	if version <= 3:
		migrated = migrate_3_to_4(migrated)
	if version <= 4:
		migrated = migrate_4_to_5(migrated)
	if version <= 5:
		migrated = migrate_5_to_6(migrated)
	if version <= 6:
		migrated = migrate_6_to_7(migrated)
	if version <= 7:
		migrated = migrate_7_to_8(migrated)
	if version <= 8:
		migrated = migrate_8_to_9(migrated)
	if version <= 9:
		migrated = migrate_9_to_10(migrated)
	if version<=10:
		migrated = migrate_10_to_11(migrated)
	if version<=11:
		migrated = migrate_11_to_12(migrated)
	if not migrated.has("machine_inventory"):
		migrated["machine_inventory"] = {}
	if not migrated.has("machine_placements"):
		migrated["machine_placements"] = {}
	if not migrated.has("machine_operations"):
		migrated["machine_operations"] = {}
	if not migrated.has("meta"):
		migrated["meta"] = {}
	migrated["meta"]["save_version"] = CURRENT_VERSION
	var metadata: Dictionary = migrated.get("meta", {})
	if not metadata.has("saved_at") and metadata.has("saved_utc"):
		metadata["saved_at"] = Time.get_datetime_string_from_unix_time(int(metadata["saved_utc"]))
	migrated["meta"] = metadata
	# Use the existing codec for canonical integer wire values on every load.
	# This temporary validator is not a persistent gameplay owner.
	var can: WateringCanState = WateringCanState.new()
	can.configure(WATERING_CONFIG)
	var raw_can: Variant = migrated.get("watering_can",{})
	can.deserialize(raw_can if raw_can is Dictionary else {})
	migrated["watering_can"] = can.serialize()
	migrated["chicken_coop"] = ChickenCoopSaveCodec.normalize(migrated.get("chicken_coop"),_coop_day(migrated),COOP_CONFIG)
	migrated["weather"] = WeatherSaveCodec.normalize(WEATHER_CONFIG,migrated.get("weather",{}),_coop_day(migrated))
	return migrated

func migrate_3_to_4(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# Keep onboarding `quests` and every previous field intact.
	if not migrated.get("social", {}) is Dictionary:
		migrated["social"] = {}
	else:
		migrated["social"] = migrated.get("social", {})
	return migrated

func migrate_4_to_5(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var clock: Variant = migrated.get("clock",{})
	var day: int = maxi(0,DayLedgerState.number(clock.get("day_index",0))) if clock is Dictionary else 0
	# Existing balances are real; past transaction history was never saved.
	migrated["day_ledger"] = {"day_index":day,"complete":false,"entries":[]}
	migrated["day_end"] = {"phase":0,"day_index":day-1,"forced":false,"last_completed_day":day-1}
	return migrated

func _save_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIRECTORY, slot]

func migrate_5_to_6(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var raw: Variant = migrated.get("inventory",{})
	var inventory: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
	var old_capacity: int = DayLedgerState.number(inventory.get("capacity",0))
	inventory["capacity"] = maxi(InventoryState.CONFIG.default_capacity,old_capacity)
	migrated["inventory"] = inventory
	return migrated

func migrate_6_to_7(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var farm: Variant = migrated.get("farm", {})
	var plots: Variant = farm.get("plots", []) if farm is Dictionary else []
	if plots is Array:
		for entry: Variant in plots:
			if entry is Dictionary and not entry.has("consecutive_dry_days"):
				# Old saves contain no evidence of missed care; never invent it.
				entry["consecutive_dry_days"] = 0
	return migrated

func migrate_7_to_8(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var config: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")
	var farm: Variant = migrated.get("farm", {})
	var plots: Variant = farm.get("plots", []) if farm is Dictionary else []
	if plots is Array:
		for entry: Variant in plots:
			if not entry is Dictionary:
				continue
			var id: Variant = entry.get("crop_id", "")
			entry["growth_target"] = int(config.previous_growth_days.get(StringName(id), 0)) if id is String or id is StringName else 0
			entry["regrowing"] = false
	return migrated

func migrate_8_to_9(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# No historical proof of purchase; preserve all old plots/machines separately.
	migrated["land_ownership"] = {"owned_parcels":[]}
	return migrated

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

func migrate_9_to_10(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# No earlier format owned water state: grant the explicit fresh legacy default.
	migrated["watering_can"] = {"capacity":WATERING_CONFIG.base_capacity,"charges":WATERING_CONFIG.base_capacity}
	return migrated

func migrate_10_to_11(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["chicken_coop"] = ChickenCoopSaveCodec.empty(_coop_day(migrated))
	return migrated

func _coop_day(data: Dictionary) -> int:
	var clock: Variant = data.get("clock",{})
	var raw: Variant = clock.get("day_index",0) if clock is Dictionary else 0
	var day: int = ChickenCoopState._json_integer(raw)
	return maxi(0,day)

func migrate_11_to_12(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["weather"] = WeatherSaveCodec.normalize(WEATHER_CONFIG,migrated.get("weather",{}),_coop_day(migrated),true)
	return migrated
