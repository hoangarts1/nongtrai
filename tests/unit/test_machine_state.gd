extends GutTest

var _inventory: InventoryState
var _machine: MachineData
var _recipe: RecipeData

func before_each() -> void:
	_inventory = InventoryState.new(4)
	_machine = load("res://data/machines/stove.tres") as MachineData
	_recipe = load("res://data/recipes/stove_carrot_meal.tres") as RecipeData

func test_start_consumes_inputs_and_sets_working_state() -> void:
	assert_eq(_inventory.add_item(&"carrot", 2), 2)
	var state: MachineState = MachineState.new()
	var result: Dictionary = state.start(_machine, _recipe, _inventory, 1)
	assert_true(result["ok"])
	assert_eq(_inventory.get_quantity(&"carrot"), 0)
	assert_eq(state.status, MachineState.STATUS_WORKING)
	assert_eq(state.days_remaining, 1)

func test_missing_input_does_not_mutate_inventory_or_machine() -> void:
	_inventory.add_item(&"carrot", 1)
	var state: MachineState = MachineState.new()
	var result: Dictionary = state.start(_machine, _recipe, _inventory, 1)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"missing_input")
	assert_eq(_inventory.get_quantity(&"carrot"), 1)
	assert_eq(state.status, MachineState.STATUS_IDLE)

func test_wrong_machine_and_house_level_are_rejected() -> void:
	var oven: MachineData = load("res://data/machines/oven.tres") as MachineData
	var state: MachineState = MachineState.new()
	assert_eq(_inventory.add_item(&"carrot", 2), 2)
	var wrong_machine: Dictionary = state.start(oven, _recipe, _inventory, 3)
	assert_false(wrong_machine["ok"])
	assert_eq(wrong_machine["reason"], &"recipe_not_allowed")
	var locked: Dictionary = state.start(_machine, _recipe, _inventory, 0)
	assert_false(locked["ok"])
	assert_eq(locked["reason"], &"house_level_locked")
	assert_eq(_inventory.get_quantity(&"carrot"), 2)

func test_completion_buffers_output_after_the_required_days() -> void:
	_inventory.add_item(&"carrot", 2)
	var state: MachineState = MachineState.new()
	state.start(_machine, _recipe, _inventory, 1)
	assert_true(state.advance_day())
	assert_eq(state.status, MachineState.STATUS_BLOCKED)
	assert_eq(state.take_output(), {"item_id": &"temp_carrot_meal", "quantity": 1})
	assert_eq(state.status, MachineState.STATUS_IDLE)

func test_full_output_buffer_blocks_without_losing_state() -> void:
	var state: MachineState = MachineState.new()
	state.deserialize({
		"machine_id": "stove",
		"cell": "2,-3",
		"recipe_id": "stove_carrot_meal",
		"days_remaining": 1,
		"status": "working",
		"output_item_id": "temp_old_meal",
		"output_quantity": 1,
		"planned_output_item_id": "temp_carrot_meal",
		"planned_output_quantity": 1
	})
	assert_false(state.advance_day())
	assert_eq(state.status, MachineState.STATUS_BLOCKED)
	assert_eq(state.output_item_id, &"temp_old_meal")
	assert_eq(state.output_quantity, 1)

func test_serialize_round_trip_preserves_progress_and_output() -> void:
	_inventory.add_item(&"carrot", 2)
	var state: MachineState = MachineState.new()
	state.cell = Vector2i(-2, 4)
	state.start(_machine, _recipe, _inventory, 1)
	var saved: Dictionary = state.serialize()
	var restored: MachineState = MachineState.new()
	restored.deserialize(saved)
	assert_eq(restored.machine_id, &"stove")
	assert_eq(restored.cell, Vector2i(-2, 4))
	assert_eq(restored.recipe_id, &"stove_carrot_meal")
	assert_eq(restored.days_remaining, 1)
	assert_eq(restored.status, MachineState.STATUS_WORKING)
	assert_true(restored.advance_day())
	assert_eq(restored.take_output()["item_id"], &"temp_carrot_meal")

func test_supplied_machine_assets_have_manifest_states() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/machines/machines_manifest.json"))
	assert_true(manifest.has("machines"))
	assert_eq(manifest["machines"].size(), 7)
	for machine_id: String in manifest["machines"]:
		var files: Array = manifest["machines"][machine_id]["files"]
		assert_eq(files.size(), 3)
		for file_stem: String in files:
			assert_true(FileAccess.file_exists("res://assets/machines/%s/%s.png" % [machine_id, file_stem]))
