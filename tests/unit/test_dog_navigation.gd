extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_real_static_water_farm_buildings_and_signed_map_edges() -> void:
	var nav: DogNavigation = DogNavigation.new()
	assert_false(nav.is_walkable(Vector2i.ZERO))
	assert_true(nav.configure(CONFIG))
	for region: Rect2i in CONFIG.npc_world.locations.get_solid_regions():
		for y: int in range(region.position.y, region.end.y):
			for x: int in range(region.position.x, region.end.x):
				if CONFIG.world.player_region.has_point(Vector2i(x, y)): assert_false(nav.is_walkable(Vector2i(x, y)))
	assert_true(nav.is_walkable(CONFIG.world.player_region.position))
	assert_false(nav.is_walkable(CONFIG.world.player_region.end))
	var origin: Vector2i = CONFIG.world.player_region.position
	var path: Array[Vector2i] = nav.route(origin, origin + Vector2i(5, 0))
	assert_eq(path.front(), origin)
	assert_eq(path.back(), origin + Vector2i(5, 0))
	for index: int in range(1, path.size()):
		var edge: Vector2i = path[index] - path[index - 1]
		assert_eq(absi(edge.x) + absi(edge.y), 1)
	assert_eq(nav.route(origin, Vector2i.ZERO), [])

func test_changed_footprint_reroutes_and_equivalent_context_does_not_rebuild() -> void:
	var nav: DogNavigation = DogNavigation.new()
	assert_true(nav.configure(CONFIG))
	var origin: Vector2i = Vector2i(-4, -10)
	var target: Vector2i = Vector2i(4, -10)
	var wall: Array[Rect2i] = [Rect2i(0, -18, 1, 39)]
	assert_true(nav.set_dynamic_obstacles(wall))
	assert_eq(nav.route(origin, target), [])
	var reached: Dictionary = nav.reachable(origin)
	assert_true(reached.ok)
	assert_false(reached.distances.has(target))
	var builds: int = nav.get_rebuild_count()
	for _index: int in range(100): assert_true(nav.set_dynamic_obstacles(wall))
	assert_eq(nav.get_rebuild_count(), builds)
	var wire: Dictionary = nav.serialize()
	assert_true(nav.deserialize(JSON.parse_string(JSON.stringify(wire, "", true, true))))
	assert_eq(nav.get_rebuild_count(), builds)
	wall.clear()
	assert_eq(nav.serialize(), wire)
	assert_true(nav.set_dynamic_obstacles(wall))
	assert_false(nav.route(origin, target).is_empty())
	assert_eq(nav.get_rebuild_count(), builds + 1)

func test_derived_context_and_reachable_results_detached_and_invalid_restore_atomic() -> void:
	var nav: DogNavigation = DogNavigation.new()
	assert_true(nav.configure(CONFIG))
	var wire: Dictionary = nav.serialize()
	var builds: int = nav.get_rebuild_count()
	assert_false(nav.deserialize({}))
	assert_eq(nav.serialize(), wire)
	assert_eq(nav.get_rebuild_count(), builds)
	var reachable: Dictionary = nav.reachable(CONFIG.world.player_region.position)
	assert_true(reachable.ok)
	assert_lte(reachable.cells.size(), CONFIG.world.player_region.get_area())
	reachable.cells.clear()
	reachable.distances.clear()
	assert_true(nav.is_walkable(CONFIG.world.player_region.position))
	wire.dynamic.append({"x": -18, "y": -18, "w": 1, "h": 1})
	assert_true(nav.is_walkable(CONFIG.world.player_region.position))
