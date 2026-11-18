extends GutTest

const CATALOG: SceneryArtCatalog = preload("res://data/art/world/isometric_scenery_catalog.tres")

func test_all_29_canonical_members_import_at_their_measured_dimensions_and_pivots() -> void:
	assert_eq(CATALOG.entries.size(), 29)
	assert_eq(CATALOG.validation_errors(), PackedStringArray())
	assert_eq(DataValidator.validate_scenery_catalog(CATALOG), PackedStringArray())
	for entry: Dictionary in CATALOG.entries:
		var texture: Texture2D = load(entry.path) as Texture2D
		assert_eq(Vector2i(texture.get_size()), entry.image_size)
		assert_eq(entry.scale, Vector2.ONE)
		if entry.kind in [&"rock", &"grass_clump"]:
			assert_eq(entry.pivot, Vector2(64, 128), "Existing canvases keep their exact old offset")
		else:
			var image: Image = texture.get_image()
			var used: Rect2i = image.get_used_rect()
			assert_eq(entry.pivot, Vector2(image.get_width()/2.0, used.end.y))
		assert_eq(entry.blocks, String(entry.id).begins_with("rock_large_"))

func test_member_identity_path_group_and_collision_corruption_are_rejected() -> void:
	for field: String in ["id", "path", "kind", "size", "variant", "blocks"]:
		var catalog: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
		catalog.entries[0][field] = {"id":&"unknown", "path":"res://assets/decor/flower_0.png", "kind":&"object", "size":&"huge", "variant":-1, "blocks":true}[field]
		assert_false(catalog.validation_errors().is_empty(), field)
	var missing: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
	missing.entries.pop_back()
	assert_false(missing.validation_errors().is_empty())
	var duplicate: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
	duplicate.entries.append(duplicate.entries[0].duplicate(true))
	assert_false(duplicate.validation_errors().is_empty())
	assert_false(DataValidator.validate_scenery_catalog(null).is_empty())

func test_nonfinite_out_of_canvas_and_wrong_type_geometry_never_validates() -> void:
	for value: Variant in [Vector2(NAN, 1), Vector2(INF, 0), Vector2(-1, 0), Vector2(1000, 0), null, 42]:
		var catalog: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
		catalog.entries[0].pivot = value
		assert_false(catalog.validation_errors().is_empty())
	for value: Variant in [Vector2.ZERO, Vector2(-1, 1), Vector2(1, INF), null]:
		var catalog: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
		catalog.entries[0].scale = value
		assert_false(catalog.validation_errors().is_empty())
	var mismatch: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
	mismatch.entries[0].image_size = Vector2i(129, 128)
	assert_false(DataValidator.validate_scenery_catalog(mismatch).is_empty(), "Actual import is checked beyond structural validity")

func test_distribution_and_numeric_integrity_fail_closed() -> void:
	for field: String in ["bands", "sizes", "tall_ids", "bucket_count", "hash_bias", "hash_multipliers"]:
		var catalog: SceneryArtCatalog = CATALOG.duplicate(true) as SceneryArtCatalog
		match field:
			"bands": catalog.bands[1].end = catalog.bands[0].end
			"sizes": catalog.sizes.reverse()
			"tall_ids": catalog.tall_ids.reverse()
			"bucket_count": catalog.bucket_count = 0
			"hash_bias": catalog.hash_bias = -9223372036854775807 - 1
			"hash_multipliers": catalog.hash_multipliers.x = 1000000001
		assert_false(catalog.validation_errors().is_empty(), field)
		assert_true(SceneryPlacementRules.compile(catalog).is_empty(), field)
	assert_true(SceneryPlacementRules.compile(null).is_empty())

func test_entry_and_compiled_snapshots_are_detached_from_resource_and_results() -> void:
	var baseline: Array[Dictionary] = CATALOG.entries.duplicate(true)
	var entry: Dictionary = CATALOG.get_entry(&"flower_0")
	entry.path = "changed"
	assert_eq(CATALOG.entries, baseline)
	assert_true(CATALOG.get_entry(&"unknown").is_empty())
	var config: Dictionary = SceneryPlacementRules.compile(CATALOG)
	config.entries[&"flower_0"].path = "changed"
	config.bands[0].end = 1
	assert_eq(CATALOG.entries, baseline)
	assert_eq(CATALOG.bands[0].end, 7)
