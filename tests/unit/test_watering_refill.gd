extends GutTest

const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const SOURCES: WaterSourceConfig = preload("res://data/water_sources.tres")
const WORLD: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
var can: WateringCanState
var service: WaterRefillService

func before_each() -> void:
	can = WateringCanState.new()
	can.configure(CONFIG)
	service = WaterRefillService.new()
	service.configure(CONFIG,can,SOURCES,WORLD.locations)

func test_each_actual_dry_bank_refills_current_capacity_once_without_changing_time() -> void:
	var clock: Dictionary = GameClock.serialize()
	for source: WaterSourceData in SOURCES.sources:
		can.deserialize({"capacity":40,"charges":3})
		var bank: Vector2i = source.access_waypoints.back()
		var before: Dictionary = can.serialize()
		var ready: Dictionary = service.can_refill(bank)
		assert_true(ready.ok)
		assert_eq(ready.source_id,source.source_id)
		assert_eq(ready.display_name_key,source.display_name_key)
		assert_eq(can.serialize(),before)
		ready["charges"] = 99
		assert_eq(can.get_charges(),3,"Detached query output cannot change the owner")
		var revision: int = can.get_refill_revision()
		var filled: Dictionary = service.refill(bank)
		assert_true(filled.ok)
		assert_eq(filled.reason,&"refilled")
		assert_eq(can.serialize(),{"capacity":40,"charges":40})
		assert_gt(can.get_refill_revision(),revision)
		revision = can.get_refill_revision()
		assert_eq(service.refill(bank).reason,&"already_full")
		assert_eq(can.get_refill_revision(),revision)
	assert_eq(GameClock.serialize(),clock)

func test_water_stone_building_far_and_outside_cells_never_refill() -> void:
	can.deserialize({"capacity":20,"charges":0})
	var before: Dictionary = can.serialize()
	var revision: int = can.get_refill_revision()
	var cells: Array[Vector2i] = [Vector2i(3,3),Vector2i(99,99),Vector2i(9,9),Vector2i(12,9)]
	for source: WaterSourceData in SOURCES.sources:
		cells.append(source.label_cell)
	for cell: Vector2i in cells:
		assert_false(service.can_refill(cell).ok)
		assert_false(service.refill(cell).ok)
		assert_eq(can.serialize(),before)
		assert_eq(can.get_refill_revision(),revision)

func test_context_identity_missing_and_malformed_data_fail_closed() -> void:
	for broken: WaterRefillService in [WaterRefillService.new()]:
		assert_false(broken.can_refill(Vector2i(7,9)).ok)
		assert_false(broken.refill(Vector2i(7,9)).ok)
	var locations: WorldLocations = WORLD.locations.duplicate() as WorldLocations
	locations.water_sources = null
	service.configure(CONFIG,can,SOURCES,locations)
	assert_eq(service.refill(Vector2i(7,9)).reason,&"invalid_service")
	var bad: WaterSourceConfig = SOURCES.duplicate() as WaterSourceConfig
	bad.clearance_cells = -1
	locations.water_sources = bad
	service.configure(CONFIG,can,bad,locations)
	assert_false(service.refill(Vector2i(7,9)).ok)
	assert_true(SOURCES.validation_errors().is_empty())
	assert_eq(can.get_charges(),20)

func test_added_static_bank_blocker_rejects_refill_without_mutating_original_data() -> void:
	var locations: WorldLocations = WORLD.locations.duplicate() as WorldLocations
	locations.solid_rects = WORLD.locations.solid_rects.duplicate()
	locations.solid_rects.append(Rect2i(7,9,1,1))
	service.configure(CONFIG,can,SOURCES,locations)
	can.deserialize({"capacity":20,"charges":1})
	assert_false(service.refill(Vector2i(7,9)).ok)
	assert_eq(can.get_charges(),1)
	assert_false(WORLD.locations.solid_rects.has(Rect2i(7,9,1,1)))

func test_refill_invalidates_old_debit_refund_without_adding_another_owner() -> void:
	assert_true(can.try_consume_one(20))
	var old_revision: int = can.get_refill_revision()
	assert_true(service.refill(Vector2i(7,9)).ok)
	assert_true(can.try_consume_one(20))
	assert_false(can.refund_one(old_revision))
	assert_eq(can.serialize(),{"capacity":20,"charges":19})
