extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_native_json_negative_boundary_cells_and_empty_localized_default() -> void:
	for cell: Vector2i in [CONFIG.world.player_region.position, CONFIG.world.player_region.end - Vector2i.ONE, Vector2i.ZERO]:
		var raw: Dictionary = {"name": "", "cell_x": cell.x, "cell_y": cell.y}
		var parsed: Dictionary = JSON.parse_string(JSON.stringify(raw, "", true, true))
		assert_eq(DogSnapshotCodec.decode(CONFIG, parsed).snapshot, raw)
	var named: Dictionary = DogSnapshotCodec.decode(CONFIG, {"name": " Sóc ", "cell_x": 0.0, "cell_y": -1.0})
	assert_true(named.ok)
	assert_eq(named.snapshot, {"name": "Sóc", "cell_x": 0, "cell_y": -1})

func test_invalid_unknown_missing_bool_fraction_nonfinite_and_int_overflow_fail() -> void:
	for raw: Variant in [null, [], {}, {"name": "Milo", "cell_x": 0}, {"name": "Milo", "cell_x": 0, "cell_y": 0, "route": []}, {"name": 1, "cell_x": 0, "cell_y": 0}]:
		assert_false(DogSnapshotCodec.decode(CONFIG, raw).ok)
	for coordinate: Variant in [true, false, 0.5, NAN, INF, -INF, 2147483648, -2147483649, "0"]:
		assert_false(DogSnapshotCodec.decode(CONFIG, {"name": "Milo", "cell_x": coordinate, "cell_y": 0}).ok)
	assert_false(DogSnapshotCodec.decode(CONFIG, {"name": "Milo", "cell_x": CONFIG.world.player_region.end.x, "cell_y": 0}).ok)
