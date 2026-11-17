extends GutTest

func test_machine_manifest_contains_supplied_visual_contract() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/machines/machines_manifest.json"))
	assert_true(parsed is Dictionary)
	var manifest: Dictionary = parsed
	var canvas: Array = manifest["canvas_2x"]
	var pivot: Array = manifest["pivot_2x"]
	assert_eq(int(canvas[0]), 128)
	assert_eq(int(canvas[1]), 152)
	assert_eq(int(pivot[0]), 64)
	assert_eq(int(pivot[1]), 120)
	var machines: Dictionary = manifest["machines"]
	assert_eq(machines.size(), 7)
	for machine_id: String in ["stove", "mill", "press", "barrel", "oven", "dryer", "roaster"]:
		var files: Array = machines[machine_id]["files"]
		assert_eq(files.size(), 3)
		for stem: String in files:
			assert_true(FileAccess.file_exists("res://assets/machines/%s/%s.png" % [machine_id, stem]))

func test_placed_machine_keeps_logical_cell_separate_from_presentation() -> void:
	var inventory: MachineInventory = MachineInventory.new()
	inventory.add_machine(&"stove")
	var placements: MachinePlacementState = MachinePlacementState.new()
	placements.configure(load("res://data/land_parcels.tres") as LandParcelData, inventory)
	assert_true(placements.place(&"stove", Vector2i(2, 3), 0)["ok"])
	var placement: Dictionary = placements.get_placement(Vector2i(2, 3))
	assert_eq(placement["cell"], Vector2i(2, 3))
	assert_eq(placement["machine_id"], &"stove")
