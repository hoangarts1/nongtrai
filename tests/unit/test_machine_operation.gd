extends GutTest

var _inventory: InventoryState
var _machine_inventory: MachineInventory
var _placements: MachinePlacementState
var _service: MachineOperationService

func before_each() -> void:
	_inventory = InventoryState.new(20)
	_machine_inventory = MachineInventory.new()
	_machine_inventory.add_machine(&"stove")
	_placements = MachinePlacementState.new()
	_placements.configure(load("res://data/land_parcels.tres") as LandParcelData, _machine_inventory)
	assert_true(_placements.place(&"stove", Vector2i(2, 3), 0)["ok"])
	_service = MachineOperationService.new()
	_service.configure(_inventory, _placements)

func test_start_uses_existing_recipe_and_advances_to_buffer() -> void:
	assert_eq(_inventory.add_item(&"carrot", 2), 2)
	var result: Dictionary = _service.start(Vector2i(2, 3), &"stove_carrot_meal", 1)
	assert_true(result["ok"])
	_service.advance_day()
	var output: Dictionary = _service.take_output(Vector2i(2, 3))
	assert_eq(output["item_id"], &"temp_carrot_meal")
	assert_eq(output["quantity"], 1)

func test_start_rejects_missing_input_without_mutation() -> void:
	var result: Dictionary = _service.start(Vector2i(2, 3), &"stove_carrot_meal", 1)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"missing_input")
	assert_true(_service.get_state(Vector2i(2, 3)).status == MachineState.STATUS_IDLE)

func test_operation_save_round_trip_preserves_work() -> void:
	_inventory.add_item(&"carrot", 2)
	assert_true(_service.start(Vector2i(2, 3), &"stove_carrot_meal", 1)["ok"])
	var restored: MachineOperationService = MachineOperationService.new()
	restored.configure(_inventory, _placements)
	restored.deserialize(_service.serialize())
	restored.advance_day()
	assert_eq(restored.take_output(Vector2i(2, 3))["item_id"], &"temp_carrot_meal")
