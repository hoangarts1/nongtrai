extends GutTest

const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_approved_policy_has_real_world_references_without_live_actor_or_save_change() -> void:
	assert_eq(CONFIG.validation_errors(), PackedStringArray())
	assert_eq(DataValidator.validate_dog_config(CONFIG), PackedStringArray())
	assert_eq(CONFIG.world, preload("res://data/isometric_world_config.tres"))
	assert_eq(CONFIG.npc_world, preload("res://data/npcs/phase8_world.tres"))
	assert_eq(CONFIG.world.player_region.size, Vector2i(39, 39))
	assert_eq(CONFIG.name_max_length, 24)
	assert_eq(CONFIG.follow_start_distance, 3)
	assert_eq(CONFIG.follow_stop_distance, 1)
	assert_eq(CONFIG.move_speed, 3.0)
	assert_eq(CONFIG.context_interval, 0.25)
	assert_eq(CONFIG.idle_wait_seconds, 3.0)
	assert_eq(CONFIG.idle_radius, 2)
	assert_eq(CONFIG.reaction_seconds, 0.8)

func test_invalid_name_distance_radius_and_nonfinite_parameters_are_rejected() -> void:
	for field: String in ["name_max_length", "follow_start_distance", "follow_stop_distance", "idle_radius", "move_speed", "context_interval", "idle_wait_seconds", "reaction_seconds"]:
		var config: DogConfig = CONFIG.frozen_copy()
		config.set(field, 0)
		assert_false(config.validation_errors().is_empty(), field)
	for field: String in ["move_speed", "context_interval", "idle_wait_seconds", "reaction_seconds"]:
		for number: float in [NAN, INF, -INF, -1.0]:
			var config: DogConfig = CONFIG.frozen_copy()
			config.set(field, number)
			assert_false(config.validation_errors().is_empty(), field)
	var copy: DogConfig = CONFIG.frozen_copy()
	copy.name_max_length = DogConfig.MAX_NAME_CODEPOINTS + 1
	assert_false(copy.validation_errors().is_empty())
	copy.name_max_length = CONFIG.name_max_length
	copy.follow_start_distance = copy.follow_stop_distance
	assert_false(copy.validation_errors().is_empty())

func test_missing_references_and_invalid_regions_fail_without_mutating_shipped_resources() -> void:
	assert_false(DataValidator.validate_dog_config(null).is_empty())
	var copy: DogConfig = CONFIG.frozen_copy()
	copy.world = null
	assert_false(copy.validation_errors().is_empty())
	copy = CONFIG.frozen_copy()
	copy.npc_world = null
	assert_false(copy.validation_errors().is_empty())
	copy = CONFIG.frozen_copy()
	copy.world.player_region = Rect2i(200, 200, 2, 2)
	assert_false(copy.validation_errors().is_empty())
	copy = CONFIG.frozen_copy()
	copy.npc_world.locations = null
	assert_false(copy.validation_errors().is_empty())
	assert_eq(CONFIG.validation_errors(), PackedStringArray())
	assert_eq(CONFIG.world.player_region.size, Vector2i(39, 39))

func test_frozen_copy_detaches_nested_world_locations_and_water_data() -> void:
	var copy: DogConfig = CONFIG.frozen_copy()
	assert_ne(copy.get_instance_id(), CONFIG.get_instance_id())
	assert_ne(copy.world.get_instance_id(), CONFIG.world.get_instance_id())
	assert_ne(copy.npc_world.locations.get_instance_id(), CONFIG.npc_world.locations.get_instance_id())
	assert_eq(copy.npc_world.locations.water_sources.world, copy.world)
	copy.world.spawn_cell = Vector2i(999, 999)
	copy.npc_world.locations.solid_rects.clear()
	copy.npc_world.locations.water_sources.sources.clear()
	assert_eq(CONFIG.world.spawn_cell, Vector2i(3, 3))
	assert_false(CONFIG.npc_world.locations.solid_rects.is_empty())
	assert_eq(CONFIG.npc_world.locations.water_sources.sources.size(), 3)
