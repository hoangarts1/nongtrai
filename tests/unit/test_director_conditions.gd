extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

func _snapshot(day: int = 7, tree: float = 29.0, diversity: float = 25.0, full: bool = true) -> Dictionary:
	var state: DirectorActivityState = DirectorActivityState.new()
	state.configure(DirectorSnapshot.ACTIVITY, 0, full)
	for index: int in range(day):
		state.advance_day(index + 1)
	var calendar: Dictionary = DirectorSnapshot.calendar(PROFILE, day)
	return DirectorSnapshot.capture(PROFILE, {"day_index": day, "minute": 360, "season": calendar.season_id, "year": calendar.year}, {"state": {"day_index": day, "metrics": {"tree_cover": tree, "biodiversity": diversity, "water_clarity": 100.0}, "triggered": ["birds", "butterflies", "clear_water"]}, "available": {"tree_cover": true, "biodiversity": true, "water_clarity": false}}, state.serialize(), {"day_index": day, "world_seed": 0, "today": "sunny", "forecast": ["sunny", "sunny", "sunny"]}, {"enabled": true, "story_unlocked": false, "debug_preview": true, "busy": false})

func _rebuild(snapshot: Dictionary) -> Dictionary:
	var source: Dictionary = snapshot.source
	return DirectorSnapshot.capture(PROFILE, source.clock, source.ecology, source.activity, source.weather, source.gates)

func test_current_threshold_sides_and_history_never_substitute_for_actual_measured_values() -> void:
	for values: Array in [[29.999, 24.999, true, false], [30.0, 25.0, false, true], [99.0, 99.0, false, true]]:
		var snapshot: Dictionary = _snapshot(7, float(values[0]), float(values[1]))
		var dust: Dictionary = DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"gentle_dust"), snapshot)
		var bloom: Dictionary = DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"butterfly_bloom"), snapshot)
		assert_eq(dust.eligible, bool(values[2]))
		assert_eq(bloom.eligible, bool(values[3]))
		assert_eq(dust.details.size(), 2)

func test_dust_reads_saved_start_day_forecast_not_todays_weather_or_a_new_roll() -> void:
	var snapshot: Dictionary = _snapshot()
	snapshot.source.weather.today = "rain"
	snapshot = _rebuild(snapshot)
	assert_true(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"gentle_dust"), snapshot).eligible)
	snapshot.source.weather.forecast[1] = "rain"
	snapshot = _rebuild(snapshot)
	var before: Dictionary = snapshot.duplicate(true)
	var result: Dictionary = DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"gentle_dust"), snapshot)
	assert_false(result.eligible)
	assert_eq(result.reason, &"rain_at_start")
	assert_eq(snapshot, before)

func test_extra_market_visit_respects_actual_existing_weekdays_and_saved_current_weather() -> void:
	assert_true(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"merchant_visit"), _snapshot(7)).eligible)
	var normal: Dictionary = _snapshot(9)
	assert_true(normal.merchant_regular.minh)
	assert_eq(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"merchant_visit"), normal).reason, &"regular_visit")
	var wet: Dictionary = _snapshot(7)
	wet.source.weather.today = "storm"
	wet = _rebuild(wet)
	assert_eq(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"merchant_visit"), wet).reason, &"rain_at_start")

func test_partial_locked_unavailable_or_forged_snapshots_cannot_satisfy_conditions() -> void:
	assert_eq(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"butterfly_bloom"), _snapshot(7, 29.0, 25.0, false)).reason, &"observations_incomplete")
	var snapshot: Dictionary = _snapshot()
	snapshot.source.ecology.available.biodiversity = false
	snapshot = _rebuild(snapshot)
	assert_eq(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"butterfly_bloom"), snapshot).reason, &"metric_unavailable")
	snapshot.metrics.biodiversity = 100.0
	assert_eq(DirectorConditionRules.evaluate(PROFILE, PROFILE.get_event(&"butterfly_bloom"), snapshot).reason, &"invalid_observations")
