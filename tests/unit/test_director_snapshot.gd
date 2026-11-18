extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

func _raw(day: int = 7, full: bool = true, quantity: int = 1) -> Array:
	var state: DirectorActivityState = DirectorActivityState.new()
	state.configure(DirectorSnapshot.ACTIVITY, 0, full)
	for index: int in range(day):
		if index == day - 1:
			state.record(index, &"item_sold", quantity)
		state.advance_day(index + 1)
	var calendar: Dictionary = DirectorSnapshot.calendar(PROFILE, day)
	return [{"day_index": day, "minute": 360, "season": calendar.season_id, "year": calendar.year}, {"state": {"day_index": day, "metrics": {"tree_cover": 29.0, "biodiversity": 25.0, "water_clarity": 99.0}, "triggered": ["birds", "clear_water"]}, "available": {"tree_cover": true, "biodiversity": true, "water_clarity": false}}, state.serialize(), {"day_index": day, "world_seed": -42, "today": "sunny", "forecast": ["sunny", "sunny", "sunny"]}, {"enabled": true, "story_unlocked": false, "debug_preview": true, "busy": false}]

func _capture(raw: Array) -> Dictionary:
	return DirectorSnapshot.capture(PROFILE, raw[0], raw[1], raw[2], raw[3], raw[4])

func test_actual_full_window_clock_seed_calendar_and_detached_snapshot_are_valid() -> void:
	var raw: Array = _raw()
	var before: Array = raw.duplicate(true)
	var snapshot: Dictionary = _capture(raw)
	assert_true(snapshot.ok)
	assert_true(snapshot.ready)
	assert_eq(snapshot.world_seed, -42)
	assert_eq(snapshot.day_index, 7)
	assert_eq(snapshot.calendar.start_day, 0)
	assert_false(snapshot.available.water_clarity)
	assert_true(snapshot.activity.available)
	assert_eq(snapshot.activity.totals.item_sold, 1)
	assert_true(DirectorSnapshot.valid(PROFILE, snapshot))
	assert_eq(raw, before)
	raw[1].state.metrics.tree_cover = 99.0
	assert_eq(snapshot.metrics.tree_cover, 29.0)
	snapshot.metrics.tree_cover = 77.0
	assert_false(DirectorSnapshot.valid(PROFILE, snapshot))
	assert_eq(before[1].state.metrics.tree_cover, 29.0)

func test_partial_unknown_disabled_locked_and_busy_inputs_never_become_ready_zeros() -> void:
	for raw: Array in [_raw(6), _raw(7, false)]:
		var result: Dictionary = _capture(raw)
		assert_true(result.ok)
		assert_false(result.ready)
		assert_eq(result.reason, &"observations_incomplete")
		assert_eq(result.activity.totals, {})
		assert_eq(result.activity.frequencies, {})
	var raw: Array = _raw()
	raw[4].enabled = false
	assert_eq(_capture(raw).reason, &"disabled")
	raw[4].enabled = true
	raw[4].debug_preview = false
	assert_eq(_capture(raw).reason, &"locked")
	raw[4].story_unlocked = true
	assert_true(_capture(raw).ready)
	raw[4].busy = true
	assert_eq(_capture(raw), {"ok": false, "reason": &"busy"})

func test_stale_unknown_malformed_and_unmeasured_water_claims_are_refused_atomically() -> void:
	for index: int in range(5):
		var raw: Array = _raw()
		raw[index] = null
		assert_false(_capture(raw).ok)
	for index: int in [1, 2, 3]:
		var raw: Array = _raw()
		if index == 1:
			raw[1].state.day_index = 6
		elif index == 2:
			raw[2].current_day = 6
		else:
			raw[3].day_index = 6
		assert_false(_capture(raw).ok)
	var raw: Array = _raw()
	raw[1].available.water_clarity = true
	assert_false(_capture(raw).ok)
	var malformed_profile: DirectorProfile = PROFILE.frozen_copy()
	malformed_profile.npc_world.npcs.append(Resource.new())
	raw = _raw()
	assert_false(DirectorSnapshot.capture(malformed_profile, raw[0], raw[1], raw[2], raw[3], raw[4]).ok)
	raw = _raw()
	raw[0].season = "summer"
	assert_false(_capture(raw).ok)
	raw = _raw()
	raw[3].world_seed = 0.5
	assert_false(_capture(raw).ok)
	raw = _raw()
	raw[4].invented_flag = true
	assert_false(_capture(raw).ok)

func test_active_day_frequency_ignores_quantity_spike_and_unclosed_day() -> void:
	var small: Dictionary = _capture(_raw(7, true, 1))
	var large: Dictionary = _capture(_raw(7, true, 100000))
	assert_eq(small.activity.frequencies, large.activity.frequencies)
	assert_eq(small.activity.frequencies.item_sold, 1.0 / 7.0)
	assert_eq(large.activity.totals.item_sold, 100000)
	var raw: Array = _raw()
	raw[2].current_counts.item_sold = 99999
	assert_eq(_capture(raw).activity, small.activity)

func test_exact_calendar_boundaries_large_days_and_native_json_are_self_consistent() -> void:
	for pair: Array in [[0, "spring"], [27, "spring"], [28, "summer"], [55, "summer"], [56, "autumn"], [84, "winter"], [112, "spring"]]:
		var result: Dictionary = DirectorSnapshot.calendar(PROFILE, int(pair[0]))
		assert_true(result.ok)
		assert_eq(result.season_id, String(pair[1]))
		assert_lte(int(result.start_day), int(pair[0]))
		assert_gt(int(result.end_day), int(pair[0]))
	var huge: Dictionary = DirectorSnapshot.calendar(PROFILE, DirectorActivityCodec.MAX_JSON_INTEGER)
	assert_true(huge.ok)
	assert_lte(int(huge.start_day), DirectorActivityCodec.MAX_JSON_INTEGER)
	assert_gt(int(huge.end_day), DirectorActivityCodec.MAX_JSON_INTEGER)
	var snapshot: Dictionary = _capture(_raw())
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(snapshot, "", true, true))
	assert_true(DirectorSnapshot.valid(PROFILE, parsed))
	parsed.day_index = 7.5
	assert_false(DirectorSnapshot.valid(PROFILE, parsed))
	parsed.day_index = 7.0
	parsed.calendar.start_day = false
	assert_false(DirectorSnapshot.valid(PROFILE, parsed))
	assert_eq(_capture(_raw()), snapshot)
