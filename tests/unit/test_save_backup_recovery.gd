extends GutTest

const SLOT: int = 780
var _saved_files: Dictionary = {}

func before_each() -> void:
	for slot: int in [0, 1, SLOT]:
		for index: int in range(4):
			var path: String = _path(slot, index)
			_saved_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
			_remove(path)

func after_each() -> void:
	for path: String in _saved_files:
		_remove(path)
		var bytes: Variant = _saved_files[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(bytes)
			file.close()
	_saved_files.clear()

func _path(slot: int, index: int = 0) -> String:
	return "user://saves/slot_%d.json%s" % [slot, "" if index == 0 else ".bak%d" % index]

func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)

func _write(slot: int, index: int, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open(_path(slot, index), FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(text)
	file.close()

func _golden(day: int = 30, timestamp: float = 100.0) -> Dictionary:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v12.json"))
	raw.clock.day_index = day
	raw.weather.day_index = day
	raw.meta.saved_utc = timestamp
	if day != 30:
		raw.chicken_coop = ChickenCoopSaveCodec.empty(day)
	return raw

func _family() -> Dictionary:
	var result: Dictionary = {}
	for index: int in range(4):
		var path: String = _path(SLOT, index)
		result[path] = FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "missing"
	return result

func test_primary_wins_and_load_inspection_never_writes_or_overwrites_actual_report() -> void:
	_write(SLOT, 0, JSON.stringify(_golden()))
	_write(SLOT, 1, JSON.stringify(_golden(29)))
	var hashes: Dictionary = _family()
	assert_eq(SaveService.load_game(SLOT).clock.day_index, 30.0)
	var report: Dictionary = SaveService.get_load_report()
	assert_eq(report.status, &"primary")
	assert_eq(report.source_index, 0)
	assert_eq(report.slot, SLOT)
	assert_true(SaveService.has_save(SLOT))
	SaveService.inspect_slot(0)
	SaveService.inspect_latest()
	SaveService.get_latest_summary()
	assert_eq(SaveService.get_load_report(), report)
	assert_eq(_family(), hashes)
	report.attempts.clear()
	assert_eq(SaveService.get_load_report(SLOT).attempts.size(), 1)

func test_corrupt_primary_and_backup_one_recover_backup_two_once_without_reroll_or_writes() -> void:
	_write(SLOT, 0, "{broken")
	_write(SLOT, 1, '{"meta":{"save_version":11.5}}')
	var raw: Dictionary = _golden()
	raw["unknown"] = {"kept": [1, 2]}
	var wire: Dictionary = JSON.parse_string(JSON.stringify(raw))
	_write(SLOT, 2, JSON.stringify(raw))
	_write(SLOT, 3, JSON.stringify(_golden(29)))
	var hashes: Dictionary = _family()
	var payload: Dictionary = SaveService.load_game(SLOT)
	assert_eq(payload.unknown, wire.unknown)
	assert_eq(payload.weather.today, raw.weather.today)
	assert_eq(payload.weather.forecast, raw.weather.forecast)
	assert_eq(payload.wallet, raw.wallet)
	var report: Dictionary = SaveService.get_load_report()
	assert_eq(report.status, &"recovered")
	assert_eq(report.source_index, 2)
	assert_eq(report.attempts.size(), 3)
	assert_eq(report.attempts[0].error, &"invalid_json")
	assert_eq(report.attempts[1].error, &"invalid_version")
	payload.unknown.kept.clear()
	assert_eq(SaveService.load_game(SLOT).unknown, wire.unknown)
	assert_eq(_family(), hashes)

func test_missing_primary_and_future_primary_block_automatic_backup_downgrade() -> void:
	_write(SLOT, 1, JSON.stringify(_golden()))
	assert_true(SaveService.load_game(SLOT).is_empty())
	assert_eq(SaveService.get_load_report().status, &"missing")
	assert_eq(SaveService.get_load_report().attempts.size(), 1)
	_write(SLOT, 0, JSON.stringify({"meta":{"save_version":SaveService.CURRENT_VERSION+1}}))
	assert_true(SaveService.load_game(SLOT).is_empty())
	assert_eq(SaveService.get_load_report().error, &"unsupported_future")
	assert_eq(SaveService.get_load_report().attempts.size(), 1)
	SaveService.delete_save(SLOT)
	assert_true(FileAccess.file_exists(_path(SLOT, 1)), "Existing delete_save semantics are preserved")
	assert_false(SaveService.has_save(SLOT), "Deleted primary must not resurrect")
	assert_true(SaveService.load_game(-1).is_empty())
	assert_eq(SaveService.get_load_report().error, &"invalid_slot")

func test_backup_three_is_last_resort_and_all_invalid_returns_explicit_failure() -> void:
	for index: int in range(4):
		_write(SLOT, index, '["not an envelope"]')
	var hashes: Dictionary = _family()
	assert_true(SaveService.load_game(SLOT).is_empty())
	assert_eq(SaveService.get_load_report().error, &"no_valid_save")
	assert_eq(SaveService.get_load_report().attempts.size(), 4)
	assert_eq(_family(), hashes)
	_write(SLOT, 3, FileAccess.get_file_as_string("res://tests/golden_saves/save_v1.json"))
	var payload: Dictionary = SaveService.load_game(SLOT)
	assert_eq(payload.meta.save_version, 17)
	assert_eq(SaveService.get_load_report().source_index, 3)
	assert_eq(SaveService.get_load_report().status, &"recovered")

func test_unreadable_primary_uses_same_ordered_codec_and_no_reader_writes() -> void:
	var reads: Array[String] = []
	var text: String = JSON.stringify(_golden())
	var wire: Dictionary = JSON.parse_string(text)
	var read: Callable = func(path: String) -> Dictionary:
		reads.append(path)
		return {"exists": true, "ok": path.ends_with(".bak1"), "text": text}
	var migrate: Callable = func(raw: Dictionary, _version: int) -> Dictionary: return raw
	var result: Dictionary = SaveLoadResolver.resolve("test", 12, migrate, 3, read)
	assert_eq(reads, ["test", "test.bak1"])
	assert_eq(result.report.source_index, 1)
	assert_eq(result.report.attempts[0].error, &"read_failed")
	assert_eq(result.payload, wire)
	assert_eq(SaveLoadResolver.resolve("test", 12, Callable(), 3, read).report.error, &"invalid_resolver")

func test_latest_uses_actual_timestamp_day_tie_and_does_not_publish_inspections() -> void:
	_write(0, 0, "{broken")
	_write(0, 1, JSON.stringify(_golden(30, 200.5)))
	_write(1, 0, JSON.stringify(_golden(31, 200.5)))
	var inspected: Dictionary = SaveService.inspect_latest()
	assert_eq(inspected.report.slot, 1)
	assert_eq(inspected.report.status, &"primary")
	assert_eq(SaveService.load_latest().clock.day_index, 31.0)
	assert_eq(SaveService.get_load_report().slot, 1)
	_write(1, 0, JSON.stringify(_golden(29, 100.0)))
	assert_eq(SaveService.load_latest().clock.day_index, 30.0)
	assert_eq(SaveService.get_load_report().status, &"recovered")
	assert_eq(SaveService.get_load_report().slot, 0)
	var report: Dictionary = SaveService.get_load_report()
	assert_eq(SaveService.get_latest_summary().day_index, 31)
	assert_eq(SaveService.get_load_report(), report)
