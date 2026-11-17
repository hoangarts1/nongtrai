extends GutTest

const SLOT: int = 76

func after_each() -> void:
	SaveService.delete_save(SLOT)

func _fixture(version: int) -> Dictionary:
	var text: String = FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT,FileAccess.WRITE)
	file.store_string(text)
	file.close()
	return JSON.parse_string(text)

func test_all_old_goldens_preserve_payloads_and_mark_unknown_history() -> void:
	for version: int in range(1,5):
		var original: Dictionary = _fixture(version)
		var loaded: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(loaded["meta"]["save_version"]),12)
		for key: String in ["clock","player","farm","quests","profile","weather","wallet","social"]:
			if original.has(key):
				var expected: Variant = original[key]
				if key == "farm":
					expected = original[key].duplicate(true)
					for plot: Dictionary in expected.get("plots", []):
						plot["consecutive_dry_days"] = 0
						plot["growth_target"] = int(preload("res://data/crop_migration_v7.tres").previous_growth_days.get(StringName(plot.get("crop_id", "")), 0))
						plot["regrowing"] = false
				if key=="weather" and not expected.is_empty():
					expected = original[key].duplicate(true)
					expected["world_seed"] = int(expected["world_seed"])
					expected["day_index"] = int(original["clock"]["day_index"])
				assert_eq(loaded[key],expected,"v%d keeps %s plus unknown-care default" % [version,key])
		assert_eq(loaded["inventory"]["slots"],original["inventory"]["slots"])
		assert_gte(int(loaded["inventory"]["capacity"]),40)
		assert_false(loaded["day_ledger"]["complete"])
		assert_eq(loaded["day_ledger"]["entries"],[])
		assert_eq(int(loaded["day_end"]["phase"]),int(DayEndState.Phase.IDLE))

func test_v5_review_golden_round_trip_keeps_ledger_and_guard() -> void:
	_fixture(5)
	var loaded: Dictionary = SaveService.load_game(SLOT)
	var ledger: DayLedgerState = DayLedgerState.new()
	ledger.deserialize(loaded["day_ledger"])
	assert_eq(ledger.totals(),{"income":105,"expense":60,"profit":45})
	var state: DayEndState = DayEndState.new()
	state.deserialize(loaded["day_end"])
	state.reconcile(int(loaded["clock"]["day_index"]))
	assert_eq(state.phase,DayEndState.Phase.REVIEW)
	assert_true(SaveService.save_game(loaded,SLOT))
	var round_trip: Dictionary = SaveService.load_game(SLOT)
	assert_eq(round_trip["day_ledger"],loaded["day_ledger"])
	assert_eq(round_trip["day_end"],loaded["day_end"])
	assert_eq(int(round_trip["wallet"]["coins"]),160)

func test_latest_prefers_new_morning_over_review_with_equal_or_fractional_timestamp() -> void:
	var previous: Dictionary = {}
	for slot: int in [0,1]:
		var path: String = "user://saves/slot_%d.json" % slot
		previous[slot] = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	for timestamp: float in [1000.0,1000.2]:
		_stamp(1,1000.0,0,1200)
		_stamp(0,timestamp,1,360)
		assert_eq(int(SaveService.load_latest()["clock"]["day_index"]),1,"Continue selects the completed morning")
	for slot: int in [0,1]:
		if String(previous[slot]).is_empty():
			SaveService.delete_save(slot)
		else:
			var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % slot,FileAccess.WRITE)
			file.store_string(previous[slot])
			file.close()

func _stamp(slot: int, timestamp: float, day: int, minute: int) -> void:
	assert_true(SaveService.save_game({"clock":{"day_index":day,"minute":minute}},slot))
	var path: String = "user://saves/slot_%d.json" % slot
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data["meta"]["saved_utc"] = timestamp
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
