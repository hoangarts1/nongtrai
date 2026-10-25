extends GutTest

const TEST_SLOT: int = 97

func after_each() -> void:
	SaveService.delete_save(TEST_SLOT)

func test_save_load_round_trip_preserves_payload() -> void:
	var payload: Dictionary = {
		"clock": {"day_index": 4, "minute": 900},
		"player": {"position": {"x": 1.5, "y": 0.0, "z": -2.0}},
		"inventory": {"capacity": 2, "slots": [{"item_id": "turnip_seed", "quantity": 3}]},
		"farm": {"plots": [{"cell_x": 1, "cell_y": 2, "tilled": true}]}
	}
	assert_true(SaveService.save_game(payload, TEST_SLOT))
	var loaded: Dictionary = SaveService.load_game(TEST_SLOT)
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 1)
	assert_eq(int((loaded["clock"] as Dictionary)["day_index"]), 4)
	assert_eq((loaded["player"] as Dictionary)["position"]["x"], 1.5)
	assert_eq(int((loaded["inventory"] as Dictionary)["slots"][0]["quantity"]), 3)

func test_corrupted_json_returns_empty_without_crashing() -> void:
	var path: String = "user://saves/slot_%d.json" % TEST_SLOT
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{not valid json")
	file.close()
	assert_true(SaveService.load_game(TEST_SLOT).is_empty())
