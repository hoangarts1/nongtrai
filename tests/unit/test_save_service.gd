extends GutTest

const TEST_SLOT: int = 97

func after_each() -> void:
	SaveService.delete_save(TEST_SLOT)

func test_save_load_round_trip_preserves_payload() -> void:
	var payload: Dictionary = {
		"clock": {"day_index": 4, "minute": 900},
		"player": {"position": {"x": 1.5, "y": 0.0, "z": -2.0}},
		"inventory": {"capacity": 2, "slots": [{"item_id": "turnip_seed", "quantity": 3}]},
		"farm": {"plots": [{"cell_x": 1, "cell_y": 2, "tilled": true}]},
		"wallet": {"coins": 250}
	}
	assert_true(SaveService.save_game(payload, TEST_SLOT))
	var loaded: Dictionary = SaveService.load_game(TEST_SLOT)
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 3)
	assert_eq(int((loaded["clock"] as Dictionary)["day_index"]), 4)
	assert_eq((loaded["player"] as Dictionary)["position"]["x"], 1.5)
	assert_eq(int((loaded["inventory"] as Dictionary)["slots"][0]["quantity"]), 3)
	assert_eq(int((loaded["wallet"] as Dictionary)["coins"]), 250)

func test_load_golden_save_v1_migrates_to_v3() -> void:
	var file: FileAccess = FileAccess.open("res://tests/golden_saves/save_v1.json", FileAccess.READ)
	assert_not_null(file, "Golden save v1 must exist")
	var text: String = file.get_as_text()
	file.close()
	
	var path: String = "user://saves/slot_%d.json" % TEST_SLOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	out.store_string(text)
	out.close()
	
	var loaded: Dictionary = SaveService.load_game(TEST_SLOT)
	assert_false(loaded.is_empty(), "Old v1 save must load successfully")
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 3, "Migrated to v3")
	assert_true(loaded.has("weather"), "Must have weather key")
	assert_true(loaded.has("wallet"), "Must have wallet key")
	assert_eq(int((loaded["wallet"] as Dictionary)["coins"]), 100, "Default 100 coins on v1 migration")

func test_load_golden_save_v2_migrates_to_v3() -> void:
	var file: FileAccess = FileAccess.open("res://tests/golden_saves/save_v2.json", FileAccess.READ)
	assert_not_null(file, "Golden save v2 must exist")
	var text: String = file.get_as_text()
	file.close()
	
	var path: String = "user://saves/slot_%d.json" % TEST_SLOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	out.store_string(text)
	out.close()
	
	var loaded: Dictionary = SaveService.load_game(TEST_SLOT)
	assert_false(loaded.is_empty(), "Old v2 save must load successfully")
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 3, "Migrated to v3")
	assert_eq((loaded["weather"] as Dictionary)["today"], "sunny", "Weather data preserved")
	assert_true(loaded.has("wallet"), "Must have wallet key")
	assert_eq(int((loaded["wallet"] as Dictionary)["coins"]), 100, "Default 100 coins on v2 migration")

func test_load_golden_save_v3() -> void:
	var file: FileAccess = FileAccess.open("res://tests/golden_saves/save_v3.json", FileAccess.READ)
	assert_not_null(file, "Golden save v3 must exist")
	var text: String = file.get_as_text()
	file.close()
	
	var path: String = "user://saves/slot_%d.json" % TEST_SLOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	out.store_string(text)
	out.close()
	
	var loaded: Dictionary = SaveService.load_game(TEST_SLOT)
	assert_false(loaded.is_empty(), "Golden save v3 must load")
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 3)
	assert_eq(int((loaded["wallet"] as Dictionary)["coins"]), 100)

func test_corrupted_json_returns_empty_without_crashing() -> void:
	var path: String = "user://saves/slot_%d.json" % TEST_SLOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{not valid json")
	file.close()
	assert_true(SaveService.load_game(TEST_SLOT).is_empty())
