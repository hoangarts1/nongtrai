extends GutTest

var _inventory: MachineInventory
var _placements: MachinePlacementState
var _build: MachineBuildService

func before_each() -> void:
	_inventory = MachineInventory.new()
	_inventory.add_machine(&"stove", 2)
	_placements = MachinePlacementState.new()
	_placements.configure(load("res://data/land_parcels.tres") as LandParcelData, _inventory)
	_build = MachineBuildService.new()
	var operations: MachineOperationService = MachineOperationService.new()
	operations.configure(InventoryState.new(), _placements)
	_build.configure(_placements, operations)

func test_valid_placement_consumes_one_machine() -> void:
	var result: Dictionary = _placements.place(&"stove", Vector2i(2, 3), 0)
	assert_true(result["ok"])
	assert_eq(_inventory.get_quantity(&"stove"), 1)
	assert_eq(_placements.get_placement(Vector2i(2, 3))["rotation"], 0)

func test_locked_cell_is_rejected_without_consuming_machine() -> void:
	var result: Dictionary = _placements.place(&"stove", Vector2i(12, 12), 0)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"cell_unavailable")
	assert_eq(_inventory.get_quantity(&"stove"), 2)

func test_occupied_cell_is_rejected() -> void:
	assert_true(_placements.place(&"stove", Vector2i(2, 3), 90)["ok"])
	var result: Dictionary = _placements.place(&"stove", Vector2i(2, 3), 180)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"cell_unavailable")
	assert_eq(_inventory.get_quantity(&"stove"), 1)

func test_invalid_rotation_is_rejected() -> void:
	var result: Dictionary = _placements.place(&"stove", Vector2i(2, 3), 45)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"invalid_rotation")
	assert_eq(_inventory.get_quantity(&"stove"), 2)

func test_remove_releases_cell_and_returns_machine() -> void:
	_placements.place(&"stove", Vector2i(2, 3), 270)
	var result: Dictionary = _placements.remove(Vector2i(2, 3))
	assert_true(result["ok"])
	assert_eq(result["machine_id"], &"stove")
	assert_eq(_inventory.get_quantity(&"stove"), 2)
	assert_true(_placements.place(&"stove", Vector2i(2, 3), 0)["ok"])

func test_save_load_preserves_cell_rotation_and_ownership() -> void:
	_placements.place(&"stove", Vector2i(-2, 4), 180)
	var saved: Dictionary = _placements.serialize()
	var restored_inventory: MachineInventory = MachineInventory.new()
	var restored: MachinePlacementState = MachinePlacementState.new()
	restored.configure(load("res://data/land_parcels.tres") as LandParcelData, restored_inventory)
	restored.deserialize(saved)
	var placement: Dictionary = restored.get_placement(Vector2i(-2, 4))
	assert_eq(placement["machine_id"], &"stove")
	assert_eq(placement["rotation"], 180)
	assert_eq(restored_inventory.get_quantity(&"stove"), 0)

func test_save_service_preserves_machine_placements() -> void:
	_placements.place(&"stove", Vector2i(2, 3), 90)
	var saved: bool = SaveService.save_game({
		"machine_inventory": _inventory.serialize(),
		"machine_placements": _placements.serialize()
	}, 0)
	assert_true(saved)
	var loaded: Dictionary = SaveService.load_game(0)
	assert_eq(loaded["machine_placements"]["placements"][0]["cell"], "2,3")
	assert_eq(loaded["machine_placements"]["placements"][0]["rotation"], 90)
	SaveService.delete_save(0)

func test_build_service_rotates_without_changing_ownership() -> void:
	assert_true(_build.place(&"stove", Vector2i(2, 3), 0)["ok"])
	var result: Dictionary = _build.rotate(Vector2i(2, 3), 90)
	assert_true(result["ok"])
	assert_eq(_placements.get_placement(Vector2i(2, 3))["rotation"], 90)
	assert_eq(_inventory.get_quantity(&"stove"), 1)

func test_build_service_moves_atomically_and_preserves_ownership() -> void:
	assert_true(_build.place(&"stove", Vector2i(2, 3), 0)["ok"])
	var result: Dictionary = _build.move(Vector2i(2, 3), Vector2i(3, 3), 180)
	assert_true(result["ok"])
	assert_true(_placements.get_placement(Vector2i(2, 3)).is_empty())
	assert_eq(_placements.get_placement(Vector2i(3, 3))["rotation"], 180)
	assert_eq(_inventory.get_quantity(&"stove"), 1)

func test_build_service_failed_move_restores_original_placement() -> void:
	assert_true(_build.place(&"stove", Vector2i(2, 3), 0)["ok"])
	assert_true(_build.place(&"stove", Vector2i(3, 3), 0)["ok"])
	var result: Dictionary = _build.move(Vector2i(2, 3), Vector2i(3, 3), 90)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"cell_unavailable")
	assert_eq(_placements.get_placement(Vector2i(2, 3))["rotation"], 0)
	assert_eq(_inventory.get_quantity(&"stove"), 0)
