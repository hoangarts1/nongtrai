extends GutTest

const SLOT: int = 78

func after_each() -> void:
	SaveService.delete_save(SLOT)

func _fixture(version: int) -> Dictionary:
	var text: String = FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT,FileAccess.WRITE)
	file.store_string(text)
	file.close()
	return JSON.parse_string(text)

func test_every_old_fixture_preserves_all_original_fields_and_defaults_unknown_care_to_zero() -> void:
	for version: int in range(1,7):
		var original: Dictionary = _fixture(version)
		var loaded: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(loaded["meta"]["save_version"]),15)
		for key: String in original:
			if key in ["meta","inventory","farm"]:
				continue
			var expected: Variant = original[key]
			if key=="weather" and not expected.is_empty():
				expected = original[key].duplicate(true)
				expected["world_seed"] = int(expected["world_seed"])
				expected["day_index"] = int(original["clock"]["day_index"])
			assert_eq(loaded[key],expected,"v%d keeps %s" % [version,key])
		var farm: Dictionary = loaded["farm"].duplicate(true)
		for plot: Dictionary in farm.get("plots",[]):
			assert_eq(int(plot["consecutive_dry_days"]),0,"No historic missed care is invented")
			plot.erase("consecutive_dry_days")
			plot.erase("growth_target")
			plot.erase("regrowing")
		assert_eq(farm,original["farm"],"Every original plot field is preserved")
		assert_eq(loaded["inventory"]["slots"],original["inventory"]["slots"])
		assert_eq(int(loaded["inventory"]["capacity"]),maxi(40,int(original["inventory"]["capacity"])))
		var snapshot: Dictionary = original.duplicate(true)
		SaveService.migrate_6_to_7(original)
		assert_eq(original,snapshot,"Migration cannot mutate its input")

func test_v7_golden_round_trip_and_reloaded_drought_continue_without_replay() -> void:
	var golden: Dictionary = _fixture(7)
	var loaded: Dictionary = SaveService.load_game(SLOT)
	var expected_farm: Dictionary = golden["farm"].duplicate(true)
	for plot: Dictionary in expected_farm["plots"]:
		plot["growth_target"] = 2
		plot["regrowing"] = false
	assert_eq(loaded["farm"],expected_farm)
	assert_eq(loaded["day_ledger"],golden["day_ledger"])
	assert_eq(loaded["day_end"],golden["day_end"])
	var farm: FarmGridState = FarmGridState.new()
	farm.deserialize(loaded["farm"])
	assert_eq(farm.get_plot(Vector2i.ZERO)["crop_id"],&"turnip")
	assert_eq(farm.get_plot(Vector2i(1,0))["withered"],true)
	assert_eq(farm.get_dry_days_remaining(Vector2i.ZERO),1)
	assert_false(farm.can_harvest(Vector2i(1,0)),"Saved withered ripe crop cannot be harvested")
	assert_true(SaveService.save_game(loaded,SLOT))
	assert_eq(SaveService.load_game(SLOT)["farm"],JSON.parse_string(JSON.stringify(loaded["farm"])))
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	assert_true(farm.get_plot(Vector2i(1,0))["withered"])
	var snapshot: Dictionary = farm.serialize()
	farm.advance_day()
	assert_eq(farm.get_plot(Vector2i.ZERO)["crop_id"],&"")
	assert_eq(farm.get_plot(Vector2i(1,0))["crop_id"],&"")
	assert_ne(farm.serialize(),snapshot)

func test_new_counter_values_are_validated_clamped_and_json_safe() -> void:
	var cases: Array[Dictionary] = [
		{"value":-2,"expected":0},{"value":0,"expected":0},{"value":1.0,"expected":1},
		{"value":2,"expected":2},{"value":99999999999999999,"expected":2},
		{"value":1.5,"expected":0},{"value":INF,"expected":0},{"value":NAN,"expected":0},
		{"value":"1","expected":0},{"value":{},"expected":0},{"value":null,"expected":0},{"value":true,"expected":0}
	]
	for entry: Dictionary in cases:
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize({"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":4,"watered":false,"withered":false,"consecutive_dry_days":entry["value"]}]})
		var plot: Dictionary = farm.get_plot(Vector2i.ZERO)
		assert_eq(plot["consecutive_dry_days"],int(entry["expected"]))
		assert_false(plot["withered"])
		assert_true(farm.can_harvest(Vector2i.ZERO))
		assert_not_null(JSON.parse_string(JSON.stringify(farm.serialize())))

func test_malformed_plot_shapes_unknown_ids_and_coordinates_do_not_crash_or_erase_valid_rows() -> void:
	var farm: FarmGridState = FarmGridState.new()
	farm.till_cell(Vector2i.ZERO)
	farm.plant_crop(Vector2i.ZERO,&"turnip")
	var snapshot: Dictionary = farm.serialize()
	farm.deserialize({"plots":"bad"})
	assert_eq(farm.serialize(),snapshot)
	var valid: Dictionary = snapshot["plots"][0].duplicate(true)
	farm.deserialize({"plots":[null,{},
		{"cell_x":INF,"crop_id":"turnip"},{"cell_x":2147483648,"crop_id":"turnip"},
		{"crop_id":{}},{"crop_id":"missing"},valid]})
	assert_eq(farm.serialize(),snapshot,"Valid row survives malformed neighbours")
	var malformed: Dictionary = {"farm":{"plots":"bad"}}
	assert_eq(SaveService.migrate_6_to_7(malformed),malformed)
