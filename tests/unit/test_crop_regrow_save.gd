extends GutTest

const SLOT: int = 79
const OLD_DAYS: Dictionary = {"turnip":2,"spring_carrot":3,"spring_pea":3,"summer_tomato":4,"summer_corn":4,"autumn_wheat":3,"autumn_pumpkin":5,"winter_radish":3,"winter_cabbage":4}

func after_each() -> void:
	SaveService.delete_save(SLOT)

func _fixture(version: int) -> Dictionary:
	var text: String = FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT,FileAccess.WRITE)
	file.store_string(text)
	file.close()
	return JSON.parse_string(text)

func test_v1_through_v7_preserve_original_fields_and_historical_targets() -> void:
	for version: int in range(1,8):
		var original: Dictionary = _fixture(version)
		var loaded: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(loaded["meta"]["save_version"]),13)
		for key: String in original:
			if key not in ["meta","inventory","farm"]:
				var expected: Variant = original[key]
				if key=="weather" and not expected.is_empty():
					expected = original[key].duplicate(true)
					expected["world_seed"] = int(expected["world_seed"])
					expected["day_index"] = int(original["clock"]["day_index"])
				assert_eq(loaded[key],expected,"v%d keeps %s" % [version,key])
		assert_eq(loaded["inventory"]["slots"],original["inventory"]["slots"])
		var normalized: Dictionary = loaded["farm"].duplicate(true)
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize(loaded["farm"])
		for plot: Dictionary in normalized.get("plots",[]):
			var target: int = int(OLD_DAYS.get(String(plot.get("crop_id","")),0))
			assert_eq(int(plot["growth_target"]),target)
			assert_false(plot["regrowing"])
			var cell: Vector2i = Vector2i(int(plot.get("cell_x",0)),int(plot.get("cell_y",0)))
			assert_eq(farm.get_growth_target(cell),target)
			if target>0:
				assert_eq(farm.get_growth_remaining(cell),maxi(0,target-int(plot.get("growth_days",0))))
			plot.erase("growth_target")
			plot.erase("regrowing")
			if version<7:
				assert_eq(int(plot["consecutive_dry_days"]),0)
				plot.erase("consecutive_dry_days")
		assert_eq(normalized,original["farm"],"Original growth/care/cells are not rewritten")

func test_old_mature_and_immature_changed_crops_keep_time_but_new_sowing_uses_new_data() -> void:
	var season: StringName = GameClock.season
	GameClock.season = &"summer"
	for id: String in ["turnip","summer_tomato","summer_corn"]:
		var old: int = OLD_DAYS[id]
		var payload: Dictionary = {"farm":{"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":id,"growth_days":old-1},{"cell_x":1,"cell_y":0,"tilled":true,"crop_id":id,"growth_days":old}]}}
		var snapshot: Dictionary = payload.duplicate(true)
		var migrated: Dictionary = SaveService.migrate_7_to_8(payload)
		assert_eq(payload,snapshot)
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize(migrated["farm"])
		assert_eq(farm.get_growth_remaining(Vector2i.ZERO),1)
		assert_true(farm.can_harvest(Vector2i(1,0)))
		farm.water_cell(Vector2i.ZERO)
		farm.advance_day()
		assert_true(farm.can_harvest(Vector2i.ZERO))
		var fresh: FarmGridState = FarmGridState.new()
		fresh.till_cell(Vector2i.ZERO)
		fresh.plant_crop(Vector2i.ZERO,StringName(id))
		assert_eq(fresh.get_growth_target(Vector2i.ZERO),4 if id=="turnip" else (5 if id=="summer_tomato" else 7))
	GameClock.season = season

func test_v8_repeat_cycle_round_trip_keeps_ledger_guard_and_next_pick_timing() -> void:
	var original: Dictionary = _fixture(8)
	var loaded: Dictionary = SaveService.load_game(SLOT)
	assert_eq(loaded["farm"],original["farm"])
	assert_eq(loaded["day_ledger"],original["day_ledger"])
	assert_eq(loaded["day_end"],original["day_end"])
	var farm: FarmGridState = FarmGridState.new()
	farm.deserialize(loaded["farm"])
	assert_eq(farm.get_plot(Vector2i.ZERO)["crop_id"],&"summer_tomato")
	assert_true(farm.get_plot(Vector2i.ZERO)["regrowing"])
	assert_eq(farm.get_growth_remaining(Vector2i.ZERO),1)
	assert_false(farm.can_harvest(Vector2i(1,0)))
	farm.water_cell(Vector2i.ZERO)
	farm.advance_day()
	assert_true(farm.can_harvest(Vector2i.ZERO))
	assert_eq(farm.harvest_cell(Vector2i.ZERO)["quantity"],2)
	loaded["farm"] = farm.serialize()
	assert_true(SaveService.save_game(loaded,SLOT))
	var reloaded: Dictionary = SaveService.load_game(SLOT)
	assert_eq(reloaded["farm"]["plots"][0]["growth_target"],2.0)
	var second: FarmGridState = FarmGridState.new()
	second.deserialize(reloaded["farm"])
	assert_false(second.can_harvest(Vector2i.ZERO))
	assert_eq(second.get_growth_remaining(Vector2i.ZERO),2)
	assert_eq(reloaded["day_ledger"],loaded["day_ledger"])
	assert_eq(reloaded["day_end"],loaded["day_end"])

func test_invalid_targets_flags_and_unknown_rows_cannot_bypass_current_duration() -> void:
	for value: Variant in [0,-1,1,1.5,NAN,INF,"1",{},true]:
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize({"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":1,"growth_target":value,"regrowing":false}]})
		assert_eq(farm.get_growth_target(Vector2i.ZERO),4)
		assert_false(farm.can_harvest(Vector2i.ZERO))
	for flag: Variant in ["true",1,{},null]:
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize({"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":1,"growth_target":2,"regrowing":flag}]})
		assert_false(farm.get_plot(Vector2i.ZERO)["regrowing"])
		assert_eq(farm.get_growth_target(Vector2i.ZERO),5)
