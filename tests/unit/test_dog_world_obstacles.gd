extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_real_water_buildings_owned_farm_and_coop_obstacles_rebuild_only_on_change() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	for region: Rect2i in r.CONFIG.npc_world.locations.get_solid_regions():
		assert_false(r.navigation.is_walkable(region.position))
	for region: Rect2i in f.main.land_ownership.get_owned_regions(): assert_false(r.navigation.is_walkable(region.position))
	var count: int = r.navigation.get_rebuild_count()
	for _i: int in range(10): r.refresh_context()
	assert_eq(r.navigation.get_rebuild_count(), count)
	f.open_coop(1000)
	assert_true(f.main.chicken_coop_runtime.execute(&"buy_coop",4).ok)
	r.refresh_context()
	assert_false(r.navigation.is_walkable(f.main.chicken_coop_runtime.CONFIG.footprint.position))
	assert_eq(r.navigation.get_rebuild_count(), count + 1)
func test_dynamic_cover_repairs_only_invalid_origin_and_stale_arrival_cannot_commit() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	var point: Vector2i = f.main.dog_state.get_cell()
	f.main.dog_state.try_set_name("Milo")
	var blocked: Array[Rect2i] = [Rect2i(point,Vector2i.ONE)]
	r.navigation.set_dynamic_obstacles(blocked)
	assert_true(r.movement.repair_invalid_origin().ok)
	assert_ne(f.main.dog_state.get_cell(), point)
	assert_eq(f.main.dog_state.get_name(), "Milo")
	assert_true(r.navigation.is_walkable(f.main.dog_state.get_cell()))

func test_actual_machine_place_move_remove_and_land_grant_refresh_context() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	var config: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
	var cells: Array[Vector2i] = []
	var region: Rect2i = config.parcels[0].region
	for y: int in range(region.position.y,region.end.y):
		for x: int in range(region.position.x,region.end.x):
			if r.navigation.is_walkable(Vector2i(x,y)): cells.append(Vector2i(x,y))
	assert_gte(cells.size(),2)
	if cells.size()<2: return
	var first: Vector2i = cells[0]
	var second: Vector2i = cells[1]
	f.main.dog_state.try_set_cell(first)
	f.main.dog_state.try_set_name("Milo")
	r.actor.reset_position()
	f.main.machine_inventory.add_machine(&"mill")
	assert_true(f.main.machine_placements.place(&"mill",first,0).ok)
	r.refresh_context()
	assert_false(r.navigation.is_walkable(first))
	assert_ne(f.main.dog_state.get_cell(),first)
	assert_eq(f.main.dog_state.get_name(),"Milo")
	assert_true(f.main.machine_placements.move(first,second,90).ok)
	r.refresh_context()
	assert_true(r.navigation.is_walkable(first))
	assert_false(r.navigation.is_walkable(second))
	assert_true(f.main.machine_placements.remove(second).ok)
	r.refresh_context()
	assert_true(r.navigation.is_walkable(second))
	assert_true(f.main.land_ownership.grant_next(config.parcels[0].parcel_id))
	r.refresh_context()
	assert_false(r.navigation.is_walkable(first))
	assert_false(r.navigation.is_walkable(second))
