## SaveService — validates, migrates and atomically stores JSON save payloads.
## API:
##   func save_game(payload: Dictionary, slot: int = 1) -> bool
##   func load_game(slot: int = 1) -> Dictionary
##   func delete_save(slot: int = 1) -> void
##   func inspect_slot(slot: int = 1) -> Dictionary
##   func inspect_latest() -> Dictionary
##   func get_load_report(slot: int = -1) -> Dictionary
##   func get_write_report() -> Dictionary
##   func migrate_5_to_6(data: Dictionary) -> Dictionary
##   func migrate_6_to_7(data: Dictionary) -> Dictionary
##   func migrate_7_to_8(data: Dictionary) -> Dictionary
##   func migrate_8_to_9(data: Dictionary) -> Dictionary
##   func migrate_9_to_10(data: Dictionary) -> Dictionary
##   func migrate_10_to_11(data: Dictionary) -> Dictionary
##   func migrate_11_to_12(data: Dictionary) -> Dictionary
##   func migrate_12_to_13(data: Dictionary) -> Dictionary
##   func migrate_13_to_14(data: Dictionary) -> Dictionary
extends Node

const CURRENT_VERSION: int = 17
const CLEARING_CONFIG: ClearingConfig = preload("res://data/clearing_config.tres")
const STORY_CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
const DOG_CONFIG: DogConfig = preload("res://data/dog_config.tres")
const DIRECTOR_INTRODUCED_VERSION: int = 14
const DIRECTOR_PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const DIRECTOR_ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const ECOLOGY_PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const ECOLOGY_SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const ECOLOGY_LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const ECOLOGY_LEGACY: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")
const WEATHER_CONFIG: WeatherProfile = preload("res://data/weather_profile.tres")
const WATERING_INTRODUCED_VERSION: int = 10
const COOP_CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const WATERING_CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const SAVE_DIRECTORY: String = "user://saves"
const MAX_BACKUPS: int = 3
var _load_reports: Dictionary = {}
var _last_load_report: Dictionary = {}
var _last_write_report: Dictionary = {}
var _write_in_progress: bool = false

func save_game(payload: Dictionary, slot: int = 1) -> bool:
	if slot < 0:
		_last_write_report = {"ok": false, "error": &"invalid_slot", "committed": false, "rollback_ok": true, "cleanup_pending": false, "recovery_paths": PackedStringArray()}
		return false
	if _write_in_progress:
		return false
	var ecology: Dictionary = _normalize_ecology(payload, payload.get("ecology"))
	if not ecology.ok:
		_last_write_report = {"ok": false, "error": &"invalid_ecology_context", "committed": false, "rollback_ok": true, "cleanup_pending": false, "recovery_paths": PackedStringArray()}
		return false
	var director: Dictionary = _normalize_director(payload, false)
	if not director.ok:
		_last_write_report = {"ok": false, "error": &"invalid_director_context", "committed": false, "rollback_ok": true, "cleanup_pending": false, "recovery_paths": PackedStringArray()}
		return false
	var story: Dictionary = _normalize_story(payload)
	if not story.ok:
		_last_write_report = {"ok":false,"error":&"invalid_story_context","committed":false,"rollback_ok":true,"cleanup_pending":false,"recovery_paths":PackedStringArray()}
		return false
	var clearing: Dictionary = ClearingSaveCodec.normalize(CLEARING_CONFIG,payload.get("clearing"))
	if not clearing.ok:
		_last_write_report = {"ok":false,"error":&"invalid_clearing_context","committed":false,"rollback_ok":true,"cleanup_pending":false,"recovery_paths":PackedStringArray()}
		return false
	var wrapped: Dictionary = {
		"meta": {
			"save_version": CURRENT_VERSION,
			"game_version": "0.1.0",
			"saved_utc": Time.get_unix_time_from_system(),
			"saved_at": Time.get_datetime_string_from_system()
		},
		"story": story.snapshot,
		"clearing": clearing.snapshot,
		"dog": _normalize_dog(payload),
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
		"ecology": ecology.snapshot,
		"director_activity": director.director_activity,
		"director": director.director,
		"quests": payload.get("quests", {}),
		"profile": payload.get("profile", {}),
		"weather": WeatherSaveCodec.pack(WEATHER_CONFIG,payload.get("weather",{}),_coop_day(payload)),
		"wallet": payload.get("wallet", {}),
		"social": payload.get("social", {}),
		"day_ledger": payload.get("day_ledger", {}),
		"day_end": payload.get("day_end", {})
	}
	_write_in_progress = true
	_last_write_report = SaveWriteTransaction.write(SaveFileStore.new(), _save_path(slot), JSON.stringify(wrapped, "\t", true, true).to_utf8_buffer(), MAX_BACKUPS)
	_write_in_progress = false
	if not _last_write_report.ok:
		push_warning("SaveService: write failed (%s), recovery copies: %s" % [_last_write_report.error, _last_write_report.recovery_paths])
	elif _last_write_report.cleanup_pending:
		push_warning("SaveService: saved with retained recovery copies: %s" % _last_write_report.recovery_paths)
	return bool(_last_write_report.ok)

func get_write_report() -> Dictionary:
	return _last_write_report.duplicate(true)

func load_game(slot: int = 1) -> Dictionary:
	var result: Dictionary = inspect_slot(slot)
	_publish_load_report(result.report)
	return result.payload

func inspect_slot(slot: int = 1) -> Dictionary:
	var result: Dictionary = {"payload": {}, "report": {"status": &"error", "error": &"invalid_slot", "source_index": -1, "attempts": []}}
	if slot >= 0:
		result = SaveLoadResolver.resolve(_save_path(slot), CURRENT_VERSION, _migrate, MAX_BACKUPS)
	result.report["slot"] = slot
	return result

func get_load_report(slot: int = -1) -> Dictionary:
	return (_last_load_report if slot < 0 else _load_reports.get(slot, {})).duplicate(true)

func _publish_load_report(report: Dictionary) -> void:
	_last_load_report = report.duplicate(true)
	_load_reports[int(report.slot)] = report.duplicate(true)

func has_save(slot: int = 1) -> bool:
	return not inspect_slot(slot).payload.is_empty()

func load_latest() -> Dictionary:
	var result: Dictionary = inspect_latest()
	_publish_load_report(result.report)
	return result.payload

func inspect_latest() -> Dictionary:
	var latest: Dictionary = {"payload": {}, "report": {"slot": -1, "status": &"missing", "error": &"missing", "source_index": -1, "attempts": []}}
	var latest_time: float = -1.0
	var latest_day: int = -1
	for slot: int in [0, 1]:
		var result: Dictionary = inspect_slot(slot)
		var payload: Dictionary = result.payload
		if payload.is_empty():
			if latest.payload.is_empty() and (result.report.error == &"unsupported_future" or latest.report.status == &"missing"):
				latest = result
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
			latest = result
	return latest

func get_latest_summary() -> Dictionary:
	var payload: Dictionary = inspect_latest().payload
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
	if version<=12:
		migrated = migrate_12_to_13(migrated)
	if version<=13:
		migrated = migrate_13_to_14(migrated)
	if version <= 14:
		migrated = migrate_14_to_15(migrated)
	if version <= 15:
		migrated = migrate_15_to_16(migrated)
	if version<=16:
		migrated = migrate_16_to_17(migrated)
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
	var ecology: Dictionary = _normalize_ecology(migrated, migrated.get("ecology"))
	migrated["ecology"] = ecology.snapshot if ecology.ok else {}
	var director: Dictionary = _normalize_director(migrated, false)
	migrated["director_activity"] = director.director_activity if director.ok else {}
	migrated["director"] = director.director if director.ok else {}
	migrated["dog"] = _normalize_dog(migrated)
	var story: Dictionary = _normalize_story(migrated)
	migrated["story"] = story.snapshot if story.ok else {}
	var clearing: Dictionary = ClearingSaveCodec.normalize(CLEARING_CONFIG,migrated.get("clearing"))
	migrated["clearing"] = clearing.snapshot if clearing.ok else {}
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

func migrate_12_to_13(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# Pre-v13 unknown ecology fields are not trusted as saved history.
	var ecology: Dictionary = _normalize_ecology(migrated, null)
	migrated["ecology"] = ecology.snapshot if ecology.ok else {}
	return migrated

func _normalize_ecology(payload: Dictionary, raw: Variant) -> Dictionary:
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	var context: Dictionary = EcologySaveContext.capture(payload, crops, ECOLOGY_LAND, ECOLOGY_LEGACY)
	var result: Dictionary = EcologySaveCodec.normalize(ECOLOGY_PROFILE, ECOLOGY_SAMPLING, raw, _coop_day(payload), crops, context)
	if not result.ok:
		push_warning("SaveService: invalid ecology context; explicit runtime fallback required")
	elif raw != null and result.reason != &"restored":
		push_warning("SaveService: ecology " + String(result.reason))
	return result

func migrate_13_to_14(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var pair: Dictionary = _normalize_director(migrated, true)
	migrated["director_activity"] = pair.director_activity if pair.ok else {}
	migrated["director"] = pair.director if pair.ok else {}
	return migrated

func _normalize_director(payload: Dictionary, legacy: bool) -> Dictionary:
	var context: Dictionary = DirectorSaveContext.capture(DIRECTOR_PROFILE, payload, DataRegistry.get_all_crops())
	if not context.ok:
		return {"ok": false, "reason": &"invalid_director_context"}
	var result: Dictionary = DirectorSaveCodec.normalize(DIRECTOR_PROFILE, DIRECTOR_ACTIVITY, payload.get("director_activity"), payload.get("director"), context, legacy)
	if result.ok and result.used_fallback and not legacy and (payload.has("director_activity") or payload.has("director")):
		push_warning("SaveService: Director " + String(result.reason))
	return result

func migrate_14_to_15(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# Earlier formats never had a dog owner. Baseline without simulating a day.
	migrated.erase("dog")
	migrated["dog"] = _normalize_dog(migrated)
	return migrated

func _normalize_dog(payload: Dictionary) -> Dictionary:
	var desired: Vector2i = DOG_CONFIG.world.spawn_cell
	var player: Variant = payload.get("player")
	if player is Dictionary:
		var position_data: Variant = player.get("position")
		if position_data is Dictionary:
			var x: Variant = position_data.get("x")
			var z: Variant = position_data.get("z")
			if (x is int or x is float) and (z is int or z is float) and is_finite(float(x)) and is_finite(float(z)) and absf(float(x)) < 2147483647.0 and absf(float(z)) < 2147483647.0:
				desired = GridMath.world_to_cell(Vector3(float(x),0.0,float(z)))
	var normalized: Dictionary = DogSaveCodec.normalize(DOG_CONFIG, payload.get("dog"), desired)
	return normalized.snapshot if normalized.ok else {}

func migrate_15_to_16(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# Pre16 has no story owner; never accept injected read/repair history.
	migrated.erase("story")
	var result: Dictionary = StorySaveCodec.normalize(STORY_CONFIG,null,migrated,true)
	migrated["story"] = result.snapshot if result.ok else {}
	return migrated

func _normalize_story(payload: Dictionary) -> Dictionary:
	return StorySaveCodec.normalize(STORY_CONFIG,payload.get("story"),payload)

func migrate_16_to_17(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	# Earlier formats cannot prove cleanup or the newly supported source.
	migrated["clearing"] = ClearingSaveCodec.empty()
	migrated["story"] = StorySaveCodec.without_clearing(STORY_CONFIG,migrated.get("story"))
	return migrated
