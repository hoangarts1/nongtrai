extends GutTest

const CELL: Vector2i = Vector2i(2,3)
const PLAYER: Vector2i = Vector2i(3,3)
const CONFIG: MachineBuildConfig = preload("res://data/machine_build_config.tres")
const WORLD: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
var _owned: MachineInventory
var _placements: MachinePlacementState
var _operations: MachineOperationService
var _build: MachineBuildService
var _farm: FarmGridState
var _bag: InventoryState
var _request: MachinePlacementRequest

func before_each() -> void:
	_owned = MachineInventory.new()
	_owned.add_machine(&"stove",4)
	_placements = MachinePlacementState.new()
	_placements.configure(preload("res://data/land_parcels.tres"),_owned)
	_bag = InventoryState.new()
	_operations = MachineOperationService.new()
	_operations.configure(_bag,_placements)
	_build = MachineBuildService.new()
	_build.configure(_placements,_operations)
	_farm = FarmGridState.new()
	_request = MachinePlacementRequest.new()
	_request.configure(_build,_farm,CONFIG,WORLD.map_region,WORLD.interaction_reach)

func _snapshot() -> Dictionary:
	return {"owned":_owned.serialize(),"placed":_placements.serialize(),"jobs":_operations.serialize(),"farm":_farm.serialize(),"bag":_bag.serialize(),"clock":GameClock.serialize()}

func test_config_data_validation_and_unconfigured_requests_fail_closed() -> void:
	assert_eq(CONFIG.allowed_region,Rect2i(0,0,6,6))
	assert_true(DataValidator.validate_machine_build_config(CONFIG,WORLD).is_empty())
	assert_false(DataValidator.validate_machine_build_config(null,WORLD).is_empty())
	var config: MachineBuildConfig = MachineBuildConfig.new()
	assert_false(DataValidator.validate_machine_build_config(config,WORLD).is_empty())
	config.allowed_region = Rect2i(100,100,2,2)
	assert_false(DataValidator.validate_machine_build_config(config,WORLD).is_empty())
	var request: MachinePlacementRequest = MachinePlacementRequest.new()
	assert_eq(request.place(&"stove",CELL,0,PLAYER).reason,&"invalid_state")
	request.configure(_build,_farm,CONFIG,WORLD.map_region,NAN)
	assert_eq(request.preview(&"stove",CELL,0,PLAYER).reason,&"invalid_state")

func test_shared_preview_is_read_only_and_confirm_consumes_exactly_one() -> void:
	var before: Dictionary = _snapshot()
	assert_true(_build.can_place(&"stove",CELL,90).ok)
	assert_true(_request.preview(&"stove",CELL,90,PLAYER).ok)
	assert_eq(_snapshot(),before)
	assert_true(_request.place(&"stove",CELL,90,PLAYER).ok)
	assert_eq(_owned.get_quantity(&"stove"),3)
	assert_eq(_placements.get_placement(CELL).rotation,90)
	before = _snapshot()
	assert_eq(_request.place(&"stove",CELL,90,PLAYER).reason,&"cell_unavailable")
	assert_eq(_snapshot(),before)

func test_invalid_player_region_range_soil_crop_locked_and_stock_leave_every_owner() -> void:
	var before: Dictionary = _snapshot()
	assert_eq(_request.place(&"stove",PLAYER,0,PLAYER).reason,&"player_occupied")
	assert_eq(_request.place(&"stove",Vector2i(-1,0),0,PLAYER).reason,&"outside_build_region")
	assert_eq(_request.place(&"stove",Vector2i(0,0),0,PLAYER).reason,&"out_of_reach")
	assert_eq(_request.place(&"stove",CELL,45,PLAYER).reason,&"invalid_rotation")
	assert_eq(_request.place(&"unknown_machine",CELL,0,PLAYER).reason,&"unknown_machine")
	var locked: Vector2i = (load("res://data/land_parcels.tres") as LandParcelData).locked_cells[0]
	assert_eq(_request.place(&"stove",locked,0,PLAYER).reason,&"cell_unavailable")
	assert_eq(_snapshot(),before)
	assert_true(_farm.till_cell(CELL))
	before = _snapshot()
	assert_eq(_request.place(&"stove",CELL,0,PLAYER).reason,&"plot_occupied")
	assert_eq(_snapshot(),before)
	var crop: CropData = DataRegistry.get_crop_for_seed(DataRegistry.get_starter_seed_for_season(GameClock.season)) as CropData
	assert_true(_farm.plant_crop(CELL,crop.crop_id))
	before = _snapshot()
	assert_eq(_request.place(&"stove",CELL,0,PLAYER).reason,&"plot_occupied")
	assert_eq(_snapshot(),before)
	assert_true(_owned.remove_machine(&"stove",4))
	before = _snapshot()
	assert_eq(_request.place(&"stove",Vector2i(3,2),0,PLAYER).reason,&"machine_not_owned")
	assert_eq(_snapshot(),before)

func test_confirm_and_return_recheck_live_stock_range_and_legacy_position() -> void:
	assert_true(_request.preview(&"stove",CELL,0,PLAYER).ok)
	assert_true(_owned.remove_machine(&"stove",4))
	var empty_stock: Dictionary = _snapshot()
	assert_eq(_request.place(&"stove",CELL,0,PLAYER).reason,&"machine_not_owned")
	assert_eq(_snapshot(),empty_stock)
	_owned.add_machine(&"stove",4)
	assert_eq(_request.place(&"stove",CELL,0,Vector2i(9,9)).reason,&"out_of_reach")
	assert_true(_request.place(&"stove",CELL,0,PLAYER).ok)
	var before: Dictionary = _snapshot()
	assert_eq(_request.return_to_storage(CELL,Vector2i(9,9)).reason,&"out_of_reach")
	assert_eq(_snapshot(),before)
	assert_true(_request.return_to_storage(CELL,PLAYER).ok)
	assert_eq(_owned.get_quantity(&"stove"),4)
	assert_eq(_request.return_to_storage(CELL,PLAYER).reason,&"no_machine")
	var legacy: Vector2i = Vector2i(7,0)
	assert_true(_build.place(&"stove",legacy,0).ok)
	assert_true(_request.return_to_storage(legacy,Vector2i(6,0)).ok,"Legacy placements outside the new region can be returned")

func test_busy_jobs_legacy_care_and_reentrant_collection_keep_d65_safety() -> void:
	assert_true(_request.place(&"stove",CELL,0,PLAYER).ok)
	assert_false(_request.can_use_farm_tool(CELL,&"hoe").ok)
	assert_false(_request.can_use_farm_tool(CELL,&"seed").ok)
	for action: StringName in [&"water",&"watering_can",&"harvest",&"shovel"]:
		assert_true(_request.can_use_farm_tool(CELL,action).ok)
	_bag.add_item(&"carrot",2)
	assert_true(_operations.start(CELL,&"stove_carrot_meal",1).ok)
	var before: Dictionary = _snapshot()
	assert_eq(_request.return_to_storage(CELL,PLAYER).reason,&"machine_busy")
	assert_eq(_snapshot(),before)
	_operations.advance_day()
	assert_eq(_request.can_return(CELL,PLAYER).reason,&"machine_busy")
	var observed: Array[StringName] = []
	_bag.item_added.connect(func(_id: StringName, _quantity: int) -> void:
		observed.append(StringName(_request.return_to_storage(CELL,PLAYER).reason))
		observed.append(StringName(_request.place(&"stove",Vector2i(3,2),0,PLAYER).reason))
	)
	assert_true(_operations.collect_output_to_inventory(CELL).ok)
	assert_eq(observed,[&"collection_busy",&"collection_busy"])
	assert_true(_request.return_to_storage(CELL,PLAYER).ok)
	assert_eq(_bag.get_quantity(&"temp_carrot_meal"),1)
