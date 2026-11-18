extends GutTest

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
var raw: Dictionary

func before_each() -> void:
	raw = {"day_index": 7, "metrics": {"tree_cover": 34.0, "water_clarity": 52.0, "biodiversity": 27.0}, "triggered": ["butterflies", "clear_water", "birds"]}

func _rejected(value: Variant) -> void:
	var result: Dictionary = EcologySnapshotCodec.decode(PROFILE, value)
	assert_false(result.ok)
	assert_false(result.has("snapshot"))
	assert_false((result.errors as PackedStringArray).is_empty())

func test_json_roundtrip_canonical_values_and_history_order_are_detached() -> void:
	var before: Dictionary = raw.duplicate(true)
	raw.extra = {"unrelated": [1, 2]}
	var result: Dictionary = EcologySnapshotCodec.decode(PROFILE, JSON.parse_string(JSON.stringify(raw)))
	assert_true(result.ok)
	assert_eq(result.snapshot.day_index, 7)
	assert_true(result.snapshot.day_index is int)
	assert_eq(result.snapshot.triggered, ["birds", "clear_water", "butterflies"])
	assert_false(result.snapshot.has("extra"))
	for value: Variant in result.snapshot.metrics.values():
		assert_true(value is float)
	result.snapshot.metrics.tree_cover = 99.0
	result.snapshot.triggered.clear()
	assert_eq(raw.metrics, before.metrics)
	assert_eq(raw.triggered, before.triggered)
	var again: Dictionary = EcologySnapshotCodec.decode(PROFILE, raw)
	assert_eq(EcologySnapshotCodec.decode(PROFILE, again.snapshot).snapshot, again.snapshot)

func test_exact_json_day_boundaries_reject_lossy_or_wrong_types() -> void:
	for day: Variant in [0, 0.0, 7.0, EcologySnapshotCodec.MAX_JSON_INTEGER]:
		raw.day_index = day
		var result: Dictionary = EcologySnapshotCodec.decode(PROFILE, raw)
		assert_true(result.ok)
		assert_eq(result.snapshot.day_index, int(day))
	for day: Variant in [true, false, "7", null, -1, -0.5, 7.5, NAN, INF, -INF, EcologySnapshotCodec.MAX_JSON_INTEGER + 1]:
		raw.day_index = day
		_rejected(raw)

func test_root_profile_and_required_parts_are_validated_without_fallback() -> void:
	for value: Variant in [null, true, 7, "{}", [], {}]:
		_rejected(value)
	assert_false(EcologySnapshotCodec.decode(null, raw).ok)
	assert_false(EcologySnapshotCodec.decode(EcologyProfile.new(), raw).ok)
	for key: String in ["day_index", "metrics", "triggered"]:
		var missing: Dictionary = raw.duplicate(true)
		missing.erase(key)
		_rejected(missing)

func test_metrics_reject_incomplete_unknown_nonstring_and_unsafe_values() -> void:
	var before: Dictionary = raw.metrics.duplicate()
	for value: Variant in [true, "30", null, NAN, INF, -INF, -0.001, 100.001, {}]:
		raw.metrics.tree_cover = value
		_rejected(raw)
	raw.metrics = before.duplicate()
	raw.metrics.erase("tree_cover")
	_rejected(raw)
	raw.metrics[&"unknown"] = 30.0
	_rejected(raw)
	raw.metrics.erase(&"unknown")
	raw.metrics[true] = 30.0
	_rejected(raw)
	for value: Variant in [null, true, [], "metrics"]:
		raw.metrics = value
		_rejected(raw)

func test_history_rejects_unknown_duplicate_nonstring_entries_but_keeps_past_crossings() -> void:
	for value: Variant in [true, {}, "birds", null, ["missing"], [true], ["birds", "birds"], [7], [null]]:
		raw.triggered = value
		_rejected(raw)
	raw.metrics = {"tree_cover": 0, "water_clarity": 0, "biodiversity": 0}
	raw.triggered = PackedStringArray(["butterflies", "birds"])
	var result: Dictionary = EcologySnapshotCodec.decode(PROFILE, raw)
	assert_true(result.ok)
	assert_eq(result.snapshot.triggered, ["birds", "butterflies"], "Falling metrics do not erase valid history")

func test_full_precision_json_keeps_values_just_below_thresholds_on_the_correct_side() -> void:
	raw.metrics = {"tree_cover": 29.999999999999996, "water_clarity": 49.99999999999999, "biodiversity": 24.999999999999996}
	var wire: Variant = JSON.parse_string(JSON.stringify(raw, "", true, true))
	var decoded: Dictionary = EcologySnapshotCodec.decode(PROFILE, wire)
	assert_true(decoded.ok)
	assert_eq(decoded.snapshot.metrics, raw.metrics)
	var state: EcologyState = EcologyState.new()
	assert_true(state.configure(PROFILE))
	assert_true(state.deserialize(decoded.snapshot))
	for id: StringName in [&"birds", &"clear_water", &"butterflies"]:
		assert_false(state.is_threshold_active(id), "JSON formatting must not round a value across a threshold")
	raw.metrics = {"tree_cover": 30.0, "water_clarity": 50.0, "biodiversity": 25.0}
	assert_true(state.deserialize(raw))
	for id: StringName in [&"birds", &"clear_water", &"butterflies"]:
		assert_true(state.is_threshold_active(id))
