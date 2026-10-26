extends GutTest

func test_four_season_schedules_night_rain_and_visit_days() -> void:
	var content: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
	var state: NpcSocialState = NpcSocialState.new()
	state.configure(content)
	for season: StringName in [&"spring", &"summer", &"autumn", &"winter"]:
		for day: int in range(7):
			for resource: Resource in content.npcs:
				var npc: NpcData = resource as NpcData
				assert_eq(state.scheduler.destination(npc, day, 1200, season, false), npc.home_location)
				assert_eq(state.scheduler.destination(npc, day, 1500, season, false), npc.home_location)
				assert_eq(state.scheduler.destination(npc, day, 1020, season, true), npc.home_location)
				var target: StringName = state.scheduler.destination(npc, day, 1020, season, false)
				var path: Array[Vector2i] = state.scheduler.route(state.scheduler.location_cell(npc.home_location), state.scheduler.location_cell(target))
				assert_false(path.is_empty(), "Every destination is reachable")
		var minh: NpcData = state.get_npc(&"minh")
		assert_eq(state.scheduler.destination(minh, 2, 1020, season, false), &"minh_market")
		assert_eq(state.scheduler.destination(minh, 3, 1020, season, false), &"minh_home")
		var linh: NpcData = state.get_npc(&"linh")
		assert_eq(state.scheduler.destination(linh, 2, 720, season, false), &"linh_stream" if season in [&"spring", &"summer"] else &"linh_garden")

func test_routes_avoid_buildings_and_rebuild_after_load() -> void:
	var content: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
	var state: NpcSocialState = NpcSocialState.new()
	state.configure(content)
	state.update_schedule(2, 1020, &"spring", false)
	for id: StringName in state.paths:
		for cell: Vector2i in state.paths[id]:
			for blocked: Rect2i in content.locations.solid_rects:
				assert_false(blocked.has_point(cell))
	state.advance_step(&"minh")
	var restored: NpcSocialState = NpcSocialState.new()
	restored.configure(content)
	restored.deserialize(state.serialize())
	restored.update_schedule(2, 1020, &"spring", false)
	assert_eq(restored.cells, state.cells)
	assert_eq(restored.targets, state.targets)
	assert_eq(restored.paths, state.paths)
