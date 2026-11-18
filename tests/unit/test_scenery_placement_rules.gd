extends GutTest

const CATALOG: SceneryArtCatalog = preload("res://data/art/world/isometric_scenery_catalog.tres")

func test_compatibility_matches_every_cell_in_current_43_square_without_new_decor() -> void:
	var config: Dictionary = SceneryPlacementRules.compile(CATALOG)
	var world: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
	var selected_ids: Dictionary = {}
	var legacy_ids: Dictionary = {}
	for y: int in range(world.scenery_region.position.y, world.scenery_region.end.y):
		for x: int in range(world.scenery_region.position.x, world.scenery_region.end.x):
			var cell: Vector2i = Vector2i(x, y)
			var bucket: int = _legacy_hash(cell) % 100
			var expected: StringName = &""
			if bucket < 18:
				var kind: String = "rock" if bucket < 7 else "grass_clump"
				var offset: Vector2i = Vector2i(17, 3) if bucket < 7 else Vector2i(5, 29)
				var size: String = ["small", "medium", "large"][_legacy_hash(cell+Vector2i(41, 11)) % 3]
				expected = StringName("%s_%s_%d" % [kind, size, _legacy_hash(cell+offset) % 3 + 1])
			var actual: Dictionary = SceneryPlacementRules.select(config, cell)
			assert_eq(StringName(actual.get("id", "")), expected)
			assert_eq(SceneryPlacementRules.cell_hash(config, cell), _legacy_hash(cell))
			if not actual.is_empty():
				assert_eq(actual.blocks, String(expected).begins_with("rock_large_"))
				assert_eq(actual.pivot, Vector2(64, 128))
				selected_ids[actual.id] = true
				legacy_ids[expected] = true
	assert_eq(selected_ids, legacy_ids, "Preserve the exact legacy set, including its correlated size/variant choices")

func test_every_bucket_boundary_and_all_nine_new_decor_are_repeatable() -> void:
	var config: Dictionary = SceneryPlacementRules.compile(CATALOG)
	var buckets: Dictionary = {}
	var members: Dictionary = {}
	var small_members: PackedStringArray = []
	for y: int in range(-21, 22):
		for x: int in range(-21, 22):
			var cell: Vector2i = Vector2i(x, y)
			var bucket: int = _legacy_hash(cell) % 100
			var selected: Dictionary = SceneryPlacementRules.select(config, cell, true)
			assert_eq(selected, SceneryPlacementRules.select(config, cell, true))
			var kind: StringName = &""
			if bucket < 7: kind = &"rock"
			elif bucket < 18: kind = &"grass_clump"
			elif bucket < 22: kind = &"flower"
			elif bucket < 25: kind = &"pebble"
			elif bucket < 30: kind = &"tuft"
			assert_eq(StringName(selected.get("kind", "")), kind)
			buckets[bucket] = true
			if not selected.is_empty():
				members[selected.id] = true
				if kind in [&"flower", &"pebble", &"tuft"] and not small_members.has(String(selected.id)):
					small_members.append(String(selected.id))
	assert_eq(buckets.size(), 100)
	small_members.sort()
	assert_eq(small_members, PackedStringArray(["flower_0", "flower_1", "flower_2", "flower_3", "pebble_0", "pebble_1", "tuft_0", "tuft_1", "tuft_2"]))
	assert_false(members.has(&"bush"))
	assert_false(members.has(&"tree_fruit"))

func test_int32_extremes_and_offsets_use_safe_int64_arithmetic_without_wrapping() -> void:
	var config: Dictionary = SceneryPlacementRules.compile(CATALOG)
	for cell: Vector2i in [Vector2i(-2147483648, -2147483648), Vector2i(2147483647, 2147483647), Vector2i(-2147483648, 2147483647)]:
		for offset: Vector2i in [Vector2i.ZERO, Vector2i(41, 11), Vector2i(-2147483648, 2147483647)]:
			var expected: int = absi((int(cell.x)+int(offset.x))*92837111 + (int(cell.y)+int(offset.y))*689287499 + 314159)
			assert_eq(SceneryPlacementRules.cell_hash(config, cell, offset), expected)
		assert_eq(SceneryPlacementRules.select(config, cell, true), SceneryPlacementRules.select(config, cell, true))
	config.multipliers = Vector2i(1000000001, 1)
	assert_eq(SceneryPlacementRules.cell_hash(config, Vector2i.ONE), -1)
	assert_true(SceneryPlacementRules.select(config, Vector2i.ONE).is_empty())
	assert_true(SceneryPlacementRules.select({}, Vector2i.ZERO).is_empty())

func test_result_mutation_and_sampling_do_not_change_resource_compiled_terms_or_rng() -> void:
	var config: Dictionary = SceneryPlacementRules.compile(CATALOG)
	var before: Dictionary = config.duplicate(true)
	var random: RandomNumberGenerator = DetRandom.make_rng(17, 5, DetRandom.TAG_WEATHER)
	var rng_state: int = random.state
	for y: int in range(-4, 5):
		for x: int in range(-4, 5):
			var result: Dictionary = SceneryPlacementRules.select(config, Vector2i(x, y), true)
			if not result.is_empty(): result.path = "changed"
	assert_eq(config, before)
	assert_eq(random.state, rng_state)
	assert_eq(CATALOG.validation_errors(), PackedStringArray())

func _legacy_hash(cell: Vector2i) -> int:
	return absi(cell.x * 92837111 + cell.y * 689287499 + 314159)
