extends GutTest

const CONFIG: DirectorActivityConfig = preload("res://data/director_activity_config.tres")

func _wire() -> Dictionary:
	var state: DirectorActivityState = DirectorActivityState.new()
	state.configure(CONFIG, 100)
	state.record(100, &"item_sold", 3)
	state.advance_day(101)
	return state.serialize()

func test_native_json_is_canonical_detached_and_retains_explicit_partial_coverage() -> void:
	var wire: Dictionary = _wire()
	var before: Dictionary = wire.duplicate(true)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(wire, "", true, true))
	var decoded: Dictionary = DirectorActivityCodec.decode(CONFIG, parsed)
	assert_true(decoded.ok)
	assert_eq(decoded.snapshot, wire)
	assert_true(decoded.snapshot.current_day is int)
	assert_true(decoded.snapshot.completed_days[0].counts.item_sold is int)
	assert_false(decoded.snapshot.completed_days[0].complete)
	decoded.snapshot.completed_days[0].counts.item_sold = 999
	assert_eq(wire, before)
	assert_eq(float(parsed.completed_days[0].counts.item_sold), 3.0)

func test_missing_extra_unordered_gapped_and_fictitious_history_fields_are_refused() -> void:
	var wire: Dictionary = _wire()
	for value: Variant in [null, true, [], {}, {"current_day": 101}]:
		assert_false(DirectorActivityCodec.decode(CONFIG, value).ok)
	for field: String in wire:
		var missing: Dictionary = wire.duplicate(true)
		missing.erase(field)
		assert_false(DirectorActivityCodec.decode(CONFIG, missing).ok)
	for mutation: Dictionary in [{"current_complete": 1}, {"current_day": -1}, {"started_day": 102}, {"completed_days": []}, {"enabled": true}]:
		var invalid: Dictionary = wire.duplicate(true)
		invalid.merge(mutation, true)
		assert_false(DirectorActivityCodec.decode(CONFIG, invalid).ok)
	for mutation: Dictionary in [{"day_index": 99}, {"day_index": 101}, {"complete": "true"}, {"extra": 0}]:
		var invalid: Dictionary = wire.duplicate(true)
		invalid.completed_days[0].merge(mutation, true)
		assert_false(DirectorActivityCodec.decode(CONFIG, invalid).ok)
	assert_eq(DirectorActivityCodec.decode(CONFIG, wire).snapshot, wire)

func test_large_safe_integers_overflow_and_hostile_fuzz_values_never_get_coerced() -> void:
	var wire: Dictionary = _wire()
	for value: Variant in [null, true, "1", -1, NAN, INF, 0.5, DirectorActivityCodec.MAX_JSON_INTEGER + 1, [], {}]:
		var invalid: Dictionary = wire.duplicate(true)
		invalid.current_counts.item_sold = value
		assert_false(DirectorActivityCodec.decode(CONFIG, invalid).ok)
	wire.current_counts.item_sold = DirectorActivityCodec.MAX_JSON_INTEGER - 3
	var decoded: Dictionary = DirectorActivityCodec.decode(CONFIG, JSON.parse_string(JSON.stringify(wire, "", true, true)))
	assert_true(decoded.ok)
	assert_eq(decoded.snapshot.current_counts.item_sold, DirectorActivityCodec.MAX_JSON_INTEGER - 3)
	wire.current_counts.item_sold += 1
	assert_false(DirectorActivityCodec.decode(CONFIG, wire).ok)
	var base: Dictionary = _wire()
	var fields: Array[String] = ["current_day", "started_day", "current_complete", "current_counts", "completed_days"]
	for index: int in range(300):
		var invalid: Dictionary = base.duplicate(true)
		invalid[fields[index % fields.size()]] = "corrupt_%d" % index
		assert_false(DirectorActivityCodec.decode(CONFIG, invalid).ok)
	assert_eq(base, _wire())

func test_unknown_or_missing_counts_wrong_config_and_day_limit_never_invent_observations() -> void:
	var wire: Dictionary = _wire()
	var missing: Dictionary = wire.duplicate(true)
	missing.current_counts.erase("plot_tilled")
	assert_false(DirectorActivityCodec.decode(CONFIG, missing).ok)
	missing.current_counts.wood_chopped = 0
	assert_false(DirectorActivityCodec.decode(CONFIG, missing).ok)
	assert_false(DirectorActivityCodec.decode(null, wire).ok)
	assert_false(DirectorActivityCodec.decode(DirectorActivityConfig.new(), wire).ok)
	var owner: DirectorActivityState = DirectorActivityState.new()
	assert_true(owner.configure(CONFIG, DirectorActivityCodec.MAX_JSON_INTEGER))
	assert_false(owner.get_window_snapshot().available)
	assert_eq(owner.serialize().completed_days, [])
	var before: Dictionary = owner.serialize()
	assert_false(owner.advance_day(DirectorActivityCodec.MAX_JSON_INTEGER + 1).ok)
	assert_eq(owner.serialize(), before)
	assert_true(owner.deserialize(DirectorActivityCodec.decode(CONFIG, JSON.parse_string(JSON.stringify(before, "", true, true))).snapshot))
