extends GutTest
const SLOT: int = 95
const CONFIG: LandExpansionConfig = preload("res://data/land_expansion_config.tres")

func after_each() -> void:
	SaveService.delete_save(SLOT)

func _write(data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func test_all_historical_goldens_migrate_without_land_grants_or_lost_progress() -> void:
	for version: int in range(1,9):
		var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		_write(old)
		var current: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(current.meta.save_version),15)
		assert_eq(current.land_ownership,{"owned_parcels":[]})
		for key: String in old:
			if key not in ["meta","farm","inventory","day_ledger","day_end"]:
				var expected: Variant = old[key]
				if key=="weather" and not expected.is_empty():
					expected = old[key].duplicate(true)
					expected["world_seed"] = int(expected["world_seed"])
					expected["day_index"] = int(old["clock"]["day_index"])
				assert_eq(current[key],expected,"Historical v%d %s" % [version,key])
		assert_eq(current.inventory.slots,old.inventory.slots)
		var old_plots: Array = old.farm.get("plots",[])
		var plots: Array = current.farm.get("plots",[])
		assert_eq(plots.size(),old_plots.size())
		for index: int in range(old_plots.size()):
			for key: String in old_plots[index]:
				assert_eq(plots[index][key],old_plots[index][key])
		var state: LandOwnershipState = LandOwnershipState.new()
		state.configure(CONFIG)
		state.deserialize(current.land_ownership)
		assert_true(state.can_use_cell(Vector2i.ZERO))
		assert_false(state.can_use_cell(Vector2i(6,0)))

func test_v9_golden_roundtrip_and_malformed_or_unknown_parcels_fail_closed() -> void:
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v9.json"))
	_write(golden)
	var current: Dictionary = SaveService.load_game(SLOT)
	assert_eq(current.land_ownership,golden.land_ownership)
	assert_true(SaveService.save_game(current,SLOT))
	var roundtrip: Dictionary = SaveService.load_game(SLOT)
	for key: String in current:
		if key!="meta":
			assert_eq(roundtrip[key],current[key])
	var state: LandOwnershipState = LandOwnershipState.new()
	state.configure(CONFIG)
	state.deserialize(roundtrip.land_ownership)
	assert_eq(LifeLandSnapshot.owned_cells(state),72)
	for bad: Variant in [{"owned_parcels":["bogus",14]}, {"owned_parcels":"farm_east_1"},{}]:
		state.deserialize(bad)
		assert_eq(LifeLandSnapshot.owned_cells(state),36)
		assert_false(state.can_use_cell(Vector2i(6,0)))
	var old: Dictionary = golden.duplicate(true)
	old.meta.save_version = 8
	_write(old)
	assert_eq(SaveService.load_game(SLOT).land_ownership,{"owned_parcels":[]},"v8 cannot smuggle a v9 purchased grant")
	golden.meta.save_version = SaveService.CURRENT_VERSION+1
	_write(golden)
	assert_eq(SaveService.load_game(SLOT),{},"Future versions stay rejected")
