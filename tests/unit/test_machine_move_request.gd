extends GutTest
const SOURCE: Vector2i = Vector2i(2,3)
const TARGET: Vector2i = Vector2i(3,2)
const PLAYER: Vector2i = Vector2i(3,3)
const PARCELS: LandParcelData = preload("res://data/land_parcels.tres")
const WORLD: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
var _owned: MachineInventory
var _placements: MachinePlacementState
var _operations: MachineOperationService
var _build: MachineBuildService
var _farm: FarmGridState
var _bag: InventoryState
var _request: MachinePlacementRequest

class RejectingOperations extends MachineOperationService:
	func forget_idle_job(cell: Vector2i) -> Dictionary:
		return {"ok":false,"reason":&"invalid_state"} if cell==TARGET else super.forget_idle_job(cell)

func before_each() -> void:
	_owned = MachineInventory.new()
	_owned.add_machine(&"stove",1)
	_placements = MachinePlacementState.new()
	_placements.configure(PARCELS,_owned)
	_bag = InventoryState.new()
	_operations = MachineOperationService.new()
	_operations.configure(_bag,_placements)
	_build = MachineBuildService.new()
	_build.configure(_placements,_operations)
	_farm = FarmGridState.new()
	_request = MachinePlacementRequest.new()
	_request.configure(_build,_farm,preload("res://data/machine_build_config.tres"),WORLD.map_region,WORLD.interaction_reach)
	assert_true(_build.place(&"stove",SOURCE,0).ok)

func _snapshot() -> Dictionary:
	return {"owned":_owned.serialize(),"placed":_placements.serialize(),"jobs":_operations.serialize(),"farm":_farm.serialize(),"bag":_bag.serialize(),"clock":GameClock.serialize(),"occupancy":(_placements.occupancy.get("_occupied_cells") as Dictionary).duplicate()}

func _source() -> Dictionary:
	return _placements.get_placement(SOURCE)

func _empty(cell: Vector2i) -> Dictionary:
	var state: MachineState = MachineState.new()
	state.machine_id = &"stove"
	state.cell = cell
	return state.serialize()

func test_readonly_preview_moves_without_spare_stock_and_cleans_only_idle_jobs_once() -> void:
	_operations.deserialize({"machines":[_empty(SOURCE),_empty(TARGET)]})
	var source: Dictionary = _source()
	var before: Dictionary = _snapshot()
	assert_eq(_owned.get_quantity(&"stove"),0)
	assert_true(_request.can_begin_move(SOURCE,PLAYER).ok)
	assert_true(_build.can_move(SOURCE,TARGET,90).ok)
	assert_true(_request.preview_move(source,TARGET,90,PLAYER).ok)
	assert_eq(_snapshot(),before)
	var detached: Dictionary = _request.can_begin_move(SOURCE,PLAYER).source
	detached.rotation = 270
	assert_eq(_source(),source,"Preview snapshot cannot mutate the owner")
	assert_eq(_request.move(source,TARGET,90,PLAYER).reason,&"moved")
	assert_true(_source().is_empty())
	assert_eq(_placements.get_placement(TARGET).rotation,90)
	assert_false(_placements.occupancy.is_occupied(SOURCE))
	assert_true(_placements.occupancy.is_occupied(TARGET))
	assert_eq(_operations.serialize(),{"machines":[]})
	assert_eq(_owned.serialize(),before.owned)
	assert_eq(_bag.serialize(),before.bag)
	assert_eq(_farm.serialize(),before.farm)
	before = _snapshot()
	assert_eq(_request.move(source,TARGET,90,PLAYER).reason,&"stale_source")
	assert_eq(_snapshot(),before)

func test_invalid_destinations_live_reach_and_missing_occupancy_preserve_all_owners() -> void:
	var source: Dictionary = _source()
	var cases: Array[Dictionary] = [
		{"cell":TARGET,"rotation":45,"player":PLAYER,"reason":&"invalid_rotation"},
		{"cell":PLAYER,"rotation":0,"player":PLAYER,"reason":&"player_occupied"},
		{"cell":Vector2i(-1,3),"rotation":0,"player":PLAYER,"reason":&"outside_build_region"},
		{"cell":Vector2i(5,5),"rotation":0,"player":PLAYER,"reason":&"out_of_reach"},
		{"cell":PARCELS.locked_cells[0],"rotation":0,"player":PLAYER,"reason":&"cell_unavailable"},
		{"cell":TARGET,"rotation":0,"player":Vector2i(9,9),"reason":&"out_of_reach"}]
	for data: Dictionary in cases:
		var before: Dictionary = _snapshot()
		assert_eq(_request.move(source,data.cell,int(data.rotation),data.player).reason,data.reason)
		assert_eq(_snapshot(),before)
	assert_true(_placements.occupancy.occupy(TARGET,Vector2i.ONE,0))
	var before: Dictionary = _snapshot()
	assert_eq(_request.move(source,TARGET,0,PLAYER).reason,&"cell_unavailable")
	assert_eq(_snapshot(),before)
	_placements.occupancy.release(TARGET,Vector2i.ONE,0)
	assert_true(_farm.till_cell(TARGET))
	before = _snapshot()
	assert_eq(_request.move(source,TARGET,0,PLAYER).reason,&"plot_occupied")
	assert_eq(_snapshot(),before)
	var crop: Resource = DataRegistry.get_crop_for_seed(DataRegistry.get_starter_seed_for_season(GameClock.season))
	assert_true(_farm.plant_crop(TARGET,crop.crop_id))
	before = _snapshot()
	assert_eq(_request.preview_move(source,TARGET,0,PLAYER).reason,&"plot_occupied")
	assert_eq(_snapshot(),before)
	_placements.occupancy.release(SOURCE,Vector2i.ONE,0)
	before = _snapshot()
	assert_eq(_request.move(source,SOURCE,90,PLAYER).reason,&"occupancy_error")
	assert_eq(_snapshot(),before)

func test_unconfigured_malformed_and_changed_sources_reject_without_adopting_replacement() -> void:
	var source: Dictionary = _source()
	var empty: MachinePlacementRequest = MachinePlacementRequest.new()
	assert_eq(empty.preview_move(source,TARGET,0,PLAYER).reason,&"invalid_state")
	for invalid: Dictionary in [{},{"cell":"2,3","rotation":0,"machine_id":&"stove"},{"cell":SOURCE,"rotation":0.0,"machine_id":&"stove"},{"cell":SOURCE,"rotation":0,"machine_id":7}]:
		var before: Dictionary = _snapshot()
		assert_eq(_request.move(invalid,TARGET,0,PLAYER).reason,&"invalid_state")
		assert_eq(_snapshot(),before)
	assert_true(_build.rotate(SOURCE,90).ok)
	var before: Dictionary = _snapshot()
	assert_eq(_request.preview_move(source,TARGET,0,PLAYER).reason,&"stale_source")
	assert_eq(_snapshot(),before)
	source = _source()
	assert_true(_build.remove(SOURCE).ok)
	before = _snapshot()
	assert_eq(_request.move(source,TARGET,0,PLAYER).reason,&"stale_source")
	assert_eq(_snapshot(),before)
	_owned.add_machine(&"mill",1)
	assert_true(_build.place(&"mill",SOURCE,0).ok)
	before = _snapshot()
	assert_eq(_request.move(source,TARGET,0,PLAYER).reason,&"stale_source")
	assert_eq(_snapshot(),before)
	assert_eq(_build.can_move(Vector2i.ZERO,TARGET,0).reason,&"no_machine")

func test_busy_ready_and_reserved_collection_reentry_remain_protected() -> void:
	var source: Dictionary = _source()
	_bag.add_item(&"carrot",2)
	assert_true(_operations.start(SOURCE,&"stove_carrot_meal",1).ok)
	for phase: int in range(2):
		var before: Dictionary = _snapshot()
		assert_eq(_request.move(source,TARGET,90,PLAYER).reason,&"machine_busy")
		assert_eq(_request.move(source,SOURCE,90,PLAYER).reason,&"machine_busy")
		assert_true(_build.can_move(SOURCE,SOURCE,90).ok,"Other facade callers retain active in-place rotation")
		assert_eq(_snapshot(),before)
		if phase==0:
			_operations.advance_day()
	var observed: Array[StringName] = []
	_bag.item_added.connect(func(_id: StringName, _count: int) -> void:
		var before: Dictionary = _snapshot()
		observed.append(StringName(_request.move(source,TARGET,0,PLAYER).reason))
		observed.append(StringName(_build.can_move(SOURCE,SOURCE,90).reason))
		assert_eq(_snapshot(),before)
	)
	assert_true(_operations.collect_output_to_inventory(SOURCE).ok)
	assert_eq(observed,[&"collection_busy",&"collection_busy"])
	assert_true(_request.move(source,TARGET,90,PLAYER).ok)
	assert_eq(_bag.get_quantity(&"temp_carrot_meal"),1)

func test_orphan_and_dirty_destination_jobs_are_not_repaired_by_preview_or_move() -> void:
	var source: Dictionary = _source()
	var orphan: Dictionary = _empty(TARGET)
	orphan.status = "blocked"
	orphan.output_item_id = "temp_carrot_meal"
	orphan.output_quantity = 1
	# The codec clears a lone output quantity; an idle recipe survives as dirty state.
	for job: Dictionary in [orphan,_empty(TARGET).merged({"recipe_id":"stove_carrot_meal"},true)]:
		_operations.deserialize({"machines":[_empty(SOURCE),job]})
		var before: Dictionary = _snapshot()
		assert_eq(_request.preview_move(source,TARGET,0,PLAYER).reason,&"invalid_state")
		assert_eq(_request.move(source,TARGET,0,PLAYER).reason,&"invalid_state")
		assert_eq(_snapshot(),before)

func test_legacy_crop_and_outer_region_source_rotate_and_move_inward_without_crop_loss() -> void:
	var legacy: Vector2i = Vector2i(6,3)
	assert_true(_build.move(SOURCE,legacy,0).ok)
	assert_true(_farm.till_cell(legacy))
	var crop: Resource = DataRegistry.get_crop_for_seed(DataRegistry.get_starter_seed_for_season(GameClock.season))
	assert_true(_farm.plant_crop(legacy,crop.crop_id))
	_operations.deserialize({"machines":[_empty(legacy)]})
	var source: Dictionary = _placements.get_placement(legacy)
	var before: Dictionary = _snapshot()
	assert_eq(_request.move(source,legacy,90,legacy).reason,&"rotated")
	assert_eq(_operations.serialize(),before.jobs)
	assert_eq(_farm.serialize(),before.farm)
	source = _placements.get_placement(legacy)
	before = _snapshot()
	assert_true(_request.move(source,legacy,90,legacy).ok,"Idle no-op cannot grant anything")
	assert_eq(_snapshot(),before)
	assert_true(_request.move(source,Vector2i(5,3),180,Vector2i(5,4)).ok)
	assert_eq(_farm.serialize(),before.farm)
	assert_eq(_owned.serialize(),before.owned)
	assert_true(_placements.get_placement(legacy).is_empty())
	assert_eq(_placements.get_placement(Vector2i(5,3)).rotation,180)

func test_partial_cleanup_rejection_restores_placement_occupancy_counts_and_jobs() -> void:
	var rejecting: RejectingOperations = RejectingOperations.new()
	rejecting.configure(_bag,_placements)
	rejecting.deserialize({"machines":[_empty(SOURCE),_empty(TARGET)]})
	_operations = rejecting
	_build.configure(_placements,rejecting)
	var source: Dictionary = _source()
	var before: Dictionary = _snapshot()
	assert_true(_request.preview_move(source,TARGET,180,PLAYER).ok)
	assert_eq(_request.move(source,TARGET,180,PLAYER).reason,&"invalid_state")
	assert_eq(_snapshot(),before,"Failed second cleanup must restore the already-cleaned source row")
