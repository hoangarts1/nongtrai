extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_canonical_context_clips_deduplicates_orders_and_roundtrips_json() -> void:
	var blocks: Array[Rect2i] = [Rect2i(-30, -30, 15, 15), Rect2i(9, 3, 2, 2), Rect2i(9, 3, 2, 2), Rect2i(100, 100, 1, 1)]
	var checked: Dictionary = DogNavigationCodec.from_regions(CONFIG, blocks)
	assert_true(checked.ok)
	assert_eq(checked.context.dynamic.size(), 2)
	assert_eq(checked.context.dynamic[0], {"x": -18, "y": -18, "w": 3, "h": 3})
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(checked.context, "", true, true))
	assert_eq(DogNavigationCodec.decode(CONFIG, parsed).context, checked.context)
	checked.context.dynamic.clear()
	assert_eq(blocks.size(), 4)

func test_wrong_bounds_unknown_fields_fraction_bool_and_overflow_rejected() -> void:
	var empty: Array[Rect2i] = []
	var original: Dictionary = DogNavigationCodec.from_regions(CONFIG, empty).context
	for value: Variant in [null, [], {}, {"bounds": original.bounds, "dynamic": [], "other": true}, {"bounds": {}, "dynamic": []}]:
		assert_false(DogNavigationCodec.decode(CONFIG, value).ok)
	for value: Variant in [true, 0.5, NAN, INF, 2147483647]:
		var raw: Dictionary = original.duplicate(true)
		raw.dynamic = [{"x": value, "y": 0, "w": 2, "h": 2}]
		assert_false(DogNavigationCodec.decode(CONFIG, raw).ok)
