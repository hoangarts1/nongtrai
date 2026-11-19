extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const EFFECTS: Script = preload("res://tests/unit/test_director_effect_projection.gd")
const CONTEXTS: Script = preload("res://tests/unit/test_director_save_context.gd")

static func current_pair() -> Dictionary:
	var owner: DirectorState = EFFECTS.active_dust()
	owner.queue_force(&"butterfly_bloom", true)
	var source: Dictionary = EFFECTS.observation(owner).source
	var payload: Dictionary = CONTEXTS.golden()
	payload.clock = source.clock.duplicate(true)
	payload.weather = source.weather.duplicate(true)
	payload.ecology = source.ecology.state.duplicate(true)
	return {"payload": payload, "director_activity": source.activity.duplicate(true), "director": owner.serialize()}

static func context(pair: Dictionary) -> Dictionary:
	return DirectorSaveContext.capture(PROFILE, pair.payload, DataRegistry.get_all_crops())

func test_valid_pair_restores_actual_coverage_terms_force_counters_trace_and_rng_exactly() -> void:
	var pair: Dictionary = current_pair()
	var before: Dictionary = pair.duplicate(true)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(pair, "", true, true))
	var result: Dictionary = DirectorSaveCodec.normalize(PROFILE, ACTIVITY, parsed.director_activity, parsed.director, context(parsed))
	assert_true(result.ok)
	assert_false(result.used_fallback)
	assert_eq(result.reason, &"restored")
	assert_eq(result.director_activity, pair.director_activity)
	assert_eq(result.director, pair.director)
	assert_eq(result.director.forced, "butterfly_bloom")
	assert_false(result.director.pending.is_empty() and result.director.active.is_empty())
	assert_false(result.director.history.back().rng_state.is_empty())
	result.director.history.clear()
	result.director_activity.completed_days.clear()
	assert_eq(pair, before)

func test_all_legacy_goldens_ignore_untrusted_future_components_and_start_partial_off_without_replay() -> void:
	var pair: Dictionary = current_pair()
	for version: int in range(1, 14):
		var payload: Dictionary = CONTEXTS.golden(version)
		var before: Dictionary = payload.duplicate(true)
		var ctx: Dictionary = DirectorSaveContext.capture(PROFILE, payload, DataRegistry.get_all_crops())
		var result: Dictionary = DirectorSaveCodec.normalize(PROFILE, ACTIVITY, pair.director_activity, pair.director, ctx, true)
		assert_true(result.ok)
		assert_true(result.used_fallback)
		assert_eq(result.reason, &"legacy_baseline")
		assert_eq(int(result.director.day_index), int(payload.clock.day_index))
		assert_false(result.director.enabled)
		assert_eq(result.director.history, [])
		assert_eq(result.director.pending, [])
		assert_false(result.director_activity.current_complete)
		assert_eq(result.director_activity.completed_days, [])
		assert_eq(payload, before)

func test_missing_corrupt_and_mismatched_pair_falls_back_together_at_actual_saved_day() -> void:
	var pair: Dictionary = current_pair()
	var ctx: Dictionary = context(pair)
	var wrong: Dictionary = pair.director.duplicate(true)
	wrong.day_index = 14
	for row: Array in [[null, pair.director], [pair.director_activity, null], [{}, {}], [true, []], [pair.director_activity, wrong]]:
		var result: Dictionary = DirectorSaveCodec.normalize(PROFILE, ACTIVITY, row[0], row[1], ctx)
		assert_true(result.ok)
		assert_true(result.used_fallback)
		assert_eq(int(result.director.day_index), 13)
		assert_eq(int(result.director_activity.current_day), 13)
		assert_false(result.director_activity.current_complete)
		assert_false(result.director.enabled)
		assert_eq(result.director.history, [])
		assert_eq(result.director_activity.completed_days, [])
	var activity: Dictionary = pair.director_activity.duplicate(true)
	activity.current_day = 12
	assert_true(DirectorSaveCodec.normalize(PROFILE, ACTIVITY, activity, pair.director, ctx).used_fallback)

func test_invalid_context_configuration_cannot_replace_components_or_modify_unrelated_progress() -> void:
	var pair: Dictionary = current_pair()
	var before: Dictionary = pair.duplicate(true)
	var ctx: Dictionary = context(pair)
	ctx.day_index = true
	assert_false(DirectorSaveCodec.normalize(PROFILE, ACTIVITY, pair.director_activity, pair.director, ctx).ok)
	assert_false(DirectorSaveCodec.normalize(PROFILE, null, pair.director_activity, pair.director, context(pair)).ok)
	assert_false(DirectorSaveCodec.normalize(null, ACTIVITY, pair.director_activity, pair.director, context(pair)).ok)
	assert_eq(pair, before)
