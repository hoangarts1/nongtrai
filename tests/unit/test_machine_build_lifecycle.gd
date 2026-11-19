extends GutTest
const SOURCE: Vector2i = Vector2i(2,3)
const TARGET: Vector2i = Vector2i(3,3)
const PARCELS: LandParcelData = preload("res://data/land_parcels.tres")
var _bag: InventoryState
var _owned: MachineInventory
var _placements: MachinePlacementState
var _operations: MachineOperationService
var _build: MachineBuildService
var _wallet: WalletState
var _clock: Dictionary
var _paused: bool
class RejectingOperations extends MachineOperationService:
	var reject: bool = true
	var rejected_cell: Vector2i
	func forget_idle_job(cell: Vector2i) -> Dictionary:
		return {"ok":false,"reason":&"invalid_state"} if reject and cell==rejected_cell else super.forget_idle_job(cell)

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_bag = InventoryState.new()
	_owned = MachineInventory.new()
	_owned.add_machine(&"stove",4)
	_placements = MachinePlacementState.new()
	_placements.configure(PARCELS,_owned)
	_operations = MachineOperationService.new()
	_operations.configure(_bag,_placements)
	_build = MachineBuildService.new()
	_build.configure(_placements,_operations)
	_wallet = WalletState.new(500)
	SaveService.delete_save(1)

func after_each() -> void:
	Input.action_release("use_tool")
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(1)

func _empty_job(cell: Vector2i, id: StringName = &"stove") -> Dictionary:
	var state: MachineState = MachineState.new()
	state.machine_id = id
	state.cell = cell
	return state.serialize()

func _start() -> void:
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	assert_eq(_bag.add_item(&"carrot",2),2)
	assert_true(_operations.start(SOURCE,&"stove_carrot_meal",1).ok)

func _snapshot() -> Dictionary:
	return {"inventory":_bag.serialize(),"machine_inventory":_owned.serialize(),"machine_placements":_placements.serialize(),"machine_operations":_operations.serialize(),"wallet":_wallet.serialize(),"clock":GameClock.serialize()}

func test_unconfigured_services_fail_closed_without_mutation() -> void:
	var build: MachineBuildService = MachineBuildService.new()
	var operations: MachineOperationService = MachineOperationService.new()
	var before: Dictionary = _snapshot()
	for command: Callable in [build.place.bind(&"stove",SOURCE,0),build.rotate.bind(SOURCE,90),build.move.bind(SOURCE,TARGET,0),build.remove.bind(SOURCE),operations.can_edit_placement.bind(SOURCE),operations.forget_idle_job.bind(SOURCE)]:
		assert_eq((command.call() as Dictionary).reason,&"invalid_state")
	build.configure(_placements,operations)
	assert_eq(build.place(&"stove",SOURCE,0).reason,&"invalid_state")
	assert_eq(_snapshot(),before)

func test_idle_move_cleans_old_and_target_rows_then_return_and_replacement_do_not_replay() -> void:
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	_operations.deserialize({"machines":[_empty_job(SOURCE),_empty_job(TARGET,&"mill")]})
	var before: Dictionary = _snapshot()
	assert_true(_operations.can_edit_placement(TARGET).ok)
	assert_eq(_snapshot(),before,"Preview is read-only")
	assert_true(_build.move(SOURCE,TARGET,180).ok)
	assert_null(_operations.get_state(SOURCE))
	assert_null(_operations.get_state(TARGET))
	assert_eq(_owned.get_quantity(&"stove"),3)
	assert_eq(_placements.get_placement(TARGET).rotation,180)
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	assert_eq(_operations.can_collect_output(SOURCE).reason,&"no_output")
	assert_true(_build.remove(TARGET).ok)
	before = _snapshot()
	assert_eq(_build.remove(TARGET).reason,&"no_machine")
	assert_eq(_snapshot(),before,"Duplicate return cannot grant a second machine")
	assert_eq(_owned.get_quantity(&"stove"),3)
	assert_eq(_bag.serialize(),before.inventory)

func test_working_and_ready_jobs_block_relocation_return_and_cleanup_but_rotate_in_place() -> void:
	_start()
	for phase: int in range(2):
		var before: Dictionary = _snapshot()
		for command: Callable in [_build.move.bind(SOURCE,TARGET,90),_build.remove.bind(SOURCE),_build.place.bind(&"stove",SOURCE,0)]:
			assert_eq((command.call() as Dictionary).reason,&"machine_busy")
			assert_eq(_snapshot(),before)
		assert_false(_operations.forget_idle_job(SOURCE).ok)
		assert_eq(_snapshot(),before)
		assert_true(_build.rotate(SOURCE,90).ok)
		assert_eq(_operations.serialize(),before.machine_operations)
		assert_eq(_build.move(SOURCE,SOURCE,270).reason,&"rotated")
		assert_eq(_placements.get_placement(SOURCE).rotation,270)
		assert_eq(_operations.serialize(),before.machine_operations)
		assert_eq(_bag.serialize(),before.inventory)
		assert_eq(_owned.serialize(),before.machine_inventory)
		_operations.advance_day()
	assert_eq(_operations.get_state(SOURCE).status,MachineState.STATUS_BLOCKED)
	assert_eq(_wallet.get_coins(),500)
	assert_eq(GameClock.serialize(),_clock)

func test_failed_targets_rotation_and_missing_ownership_never_clean_idle_rows() -> void:
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	assert_true(_build.place(&"stove",TARGET,0).ok)
	var free: Vector2i = Vector2i(4,3)
	_operations.deserialize({"machines":[_empty_job(SOURCE),_empty_job(TARGET),_empty_job(free)]})
	var before: Dictionary = _snapshot()
	for command: Callable in [_build.move.bind(SOURCE,TARGET,90),_build.move.bind(SOURCE,PARCELS.locked_cells[0],90),_build.move.bind(SOURCE,free,45),_build.rotate.bind(SOURCE,45),_build.place.bind(&"stove",PARCELS.locked_cells[0],0)]:
		assert_false((command.call() as Dictionary).ok)
		assert_eq(_snapshot(),before)
	assert_true(_owned.remove_machine(&"stove",_owned.get_quantity(&"stove")))
	before = _snapshot()
	assert_eq(_build.place(&"stove",free,0).reason,&"machine_not_owned")
	assert_eq(_snapshot(),before)
	assert_eq(_build.move(SOURCE,SOURCE,180).reason,&"rotated")
	assert_eq(_operations.serialize(),before.machine_operations,"Same-cell idle move is only rotation")

func test_orphan_and_corrupt_target_jobs_are_preserved_not_adopted() -> void:
	_start()
	_operations.advance_day()
	var ready: Dictionary = _operations.get_state(SOURCE).serialize()
	ready.cell = "%d,%d" % [TARGET.x,TARGET.y]
	var dirty_idle: Dictionary = _empty_job(TARGET)
	dirty_idle.planned_output_item_id = "temp_carrot_meal"
	dirty_idle.planned_output_quantity = 1
	var unknown: Dictionary = _empty_job(TARGET,&"unknown_machine")
	for row: Dictionary in [ready,dirty_idle,unknown]:
		_operations.deserialize({"machines":[row]})
		var before: Dictionary = _snapshot()
		for command: Callable in [_build.place.bind(&"stove",TARGET,0),_build.move.bind(SOURCE,TARGET,0),_build.rotate.bind(TARGET,90),_operations.forget_idle_job.bind(TARGET)]:
			assert_false((command.call() as Dictionary).ok)
			assert_eq(_snapshot(),before)
	_operations.deserialize({"machines":[_empty_job(SOURCE,&"mill")]})
	var before: Dictionary = _snapshot()
	assert_eq(_build.remove(SOURCE).reason,&"invalid_state")
	assert_eq(_snapshot(),before)

func test_cleanup_rejection_restores_placement_stock_jobs_and_occupancy() -> void:
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	var rejecting: RejectingOperations = RejectingOperations.new()
	rejecting.configure(_bag,_placements)
	rejecting.deserialize({"machines":[_empty_job(SOURCE)]})
	_operations = rejecting
	_build.configure(_placements,_operations)
	for command: Callable in [_build.place.bind(&"stove",TARGET,0),_build.move.bind(SOURCE,TARGET,90),_build.remove.bind(SOURCE)]:
		rejecting.rejected_cell = SOURCE if command.get_method()==&"remove" else TARGET
		var before: Dictionary = _snapshot()
		assert_eq((command.call() as Dictionary).reason,&"invalid_state")
		assert_eq(_snapshot(),before)
		assert_true(_placements.occupancy.is_occupied(SOURCE))
		assert_false(_placements.occupancy.is_occupied(TARGET))
	rejecting.reject = false
	assert_true(_build.move(SOURCE,TARGET,90).ok)
	assert_null(_operations.get_state(SOURCE))

func test_collection_callback_cannot_edit_even_after_buffer_is_reserved_idle() -> void:
	_start()
	_operations.advance_day()
	var observed: Array[StringName] = []
	_bag.item_added.connect(func(_id: StringName, _quantity: int) -> void:
		assert_eq(_operations.get_state(SOURCE).status,MachineState.STATUS_IDLE)
		for command: Callable in [_build.place.bind(&"stove",TARGET,0),_build.rotate.bind(SOURCE,90),_build.move.bind(SOURCE,SOURCE,180),_build.move.bind(SOURCE,TARGET,0),_build.remove.bind(SOURCE),_operations.forget_idle_job.bind(SOURCE)]:
			observed.append((command.call() as Dictionary).reason)
	)
	var before: Dictionary = _snapshot()
	assert_true(_operations.collect_output_to_inventory(SOURCE).ok)
	assert_eq(observed.size(),6)
	for reason: StringName in observed:
		assert_eq(reason,&"collection_busy")
	assert_eq(_placements.serialize(),before.machine_placements)
	assert_eq(_owned.serialize(),before.machine_inventory)
	assert_eq(_bag.get_quantity(&"temp_carrot_meal"),1)
	assert_true(_build.remove(SOURCE).ok)
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	assert_eq(_operations.can_collect_output(SOURCE).reason,&"no_output")
	assert_eq(_wallet.serialize(),before.wallet)
	assert_eq(GameClock.serialize(),before.clock)

func _round_trip() -> void:
	assert_true(SaveService.save_game(_snapshot(),1))
	var saved: Dictionary = SaveService.load_game(1)
	_bag.deserialize(saved.inventory)
	_owned.deserialize(saved.machine_inventory)
	_placements.deserialize(saved.machine_placements)
	_operations.deserialize(saved.machine_operations)
	_wallet.deserialize(saved.wallet)

func test_save_load_before_after_move_return_and_replacement_preserves_one_payout() -> void:
	_start()
	_round_trip()
	assert_eq(_build.move(SOURCE,TARGET,0).reason,&"machine_busy")
	assert_true(_build.rotate(SOURCE,90).ok)
	_operations.advance_day()
	_round_trip()
	assert_eq(_build.remove(SOURCE).reason,&"machine_busy")
	assert_true(_operations.collect_output_to_inventory(SOURCE).ok)
	assert_true(_build.move(SOURCE,TARGET,180).ok)
	_round_trip()
	assert_eq(_placements.get_placement(TARGET).rotation,180)
	assert_eq(_operations.can_collect_output(SOURCE).reason,&"no_machine")
	assert_eq(_operations.can_collect_output(TARGET).reason,&"no_output")
	assert_true(_build.remove(TARGET).ok)
	_round_trip()
	assert_eq(_owned.get_quantity(&"stove"),4)
	assert_true(_build.place(&"stove",SOURCE,0).ok)
	assert_eq(_operations.can_collect_output(SOURCE).reason,&"no_output")
	assert_eq(_bag.get_quantity(&"temp_carrot_meal"),1)
	assert_eq(_wallet.get_coins(),500)
	assert_eq(SaveService.CURRENT_VERSION,15)

func test_main_wires_the_real_job_owner_into_build_facade() -> void:
	SaveService.delete_save(0)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	add_child(viewport)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Vườn")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
	main.machine_inventory.add_machine(&"stove")
	assert_true(main.machine_build.place(&"stove",SOURCE,0).ok)
	main.inventory.add_item(&"carrot",2)
	assert_true(main.machine_operations.start(SOURCE,&"stove_carrot_meal",1).ok)
	assert_eq(main.machine_build.move(SOURCE,TARGET,0).reason,&"machine_busy")
	assert_eq(main.machine_build.remove(SOURCE).reason,&"machine_busy")
	assert_true(main.world.player is CharacterBody2D)
	main.machine_operations.advance_day()
	assert_true(main.machine_operations.collect_output_to_inventory(SOURCE).ok)
	assert_true(main.machine_build.move(SOURCE,TARGET,90).ok)
	assert_true(main.machine_build.remove(TARGET).ok)
	main.tool_controller.set_placement_active(true)
	Input.action_press("use_tool")
	main.tool_controller.set_placement_active(false)
	main.tool_controller.set("_hovered_cell",TARGET)
	main.tool_controller.set("_hovered_valid",true)
	var held: InputEventAction = InputEventAction.new()
	held.action = &"use_tool"
	held.pressed = true
	main.tool_controller.call("_unhandled_input",held)
	assert_true(main.farm_state.get_plot(TARGET).is_empty(),"Held confirm cannot leak into farming after placement closes")
	Input.action_release("use_tool")
	await get_tree().process_frame
	await get_tree().process_frame
	viewport.free()
	SaveService.delete_save(0)
