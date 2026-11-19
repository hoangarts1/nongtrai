extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const PAIRS: Script = preload("res://tests/unit/test_director_save_codec.gd")

func test_complete_pair_is_prepared_before_silent_exact_owner_replacement() -> void:
	var pair: Dictionary = PAIRS.current_pair()
	var activity: DirectorActivityState = DirectorActivityState.new()
	var director: DirectorState = DirectorState.new()
	activity.configure(ACTIVITY, 3)
	director.configure(PROFILE, 3)
	watch_signals(activity)
	watch_signals(director)
	var result: Dictionary = DirectorLifecycle.restore(activity, director, PROFILE, ACTIVITY, pair.director_activity, pair.director, PAIRS.context(pair))
	assert_true(result.ok)
	assert_eq(activity.serialize(), pair.director_activity)
	assert_eq(director.serialize(), pair.director)
	assert_signal_not_emitted(activity, "activity_changed")
	assert_signal_not_emitted(director, "director_changed")

func test_invalid_context_is_atomic_and_corrupt_components_reset_only_pair_with_diagnostic() -> void:
	var pair: Dictionary = PAIRS.current_pair()
	var activity: DirectorActivityState = DirectorActivityState.new()
	var director: DirectorState = DirectorState.new()
	activity.configure(ACTIVITY, 3)
	director.configure(PROFILE, 3)
	var before: Array = [activity.serialize(), director.serialize(), pair.duplicate(true)]
	var invalid: Dictionary = PAIRS.context(pair)
	invalid.day_index = true
	assert_false(DirectorLifecycle.restore(activity, director, PROFILE, ACTIVITY, {}, {}, invalid).ok)
	assert_eq([activity.serialize(), director.serialize(), pair], before)
	var result: Dictionary = DirectorLifecycle.restore(activity, director, PROFILE, ACTIVITY, {}, pair.director, PAIRS.context(pair))
	assert_true(result.ok)
	assert_true(result.used_fallback)
	assert_eq(result.reason, &"component_missing_or_invalid")
	assert_eq(activity.serialize().completed_days, [])
	assert_false(activity.serialize().current_complete)
	assert_false(director.is_enabled())
	assert_eq(director.serialize().history, [])
	assert_eq(pair, before[2])

func test_reserved_or_notifying_owner_blocks_all_pair_restore_paths() -> void:
	var pair: Dictionary = PAIRS.current_pair()
	var activity: DirectorActivityState = DirectorActivityState.new()
	var director: DirectorState = DirectorState.new()
	activity.configure(ACTIVITY, 3)
	director.configure(PROFILE, 3)
	var token: RefCounted = director.begin_day(4).token
	var before: Array = [activity.serialize(), director.serialize()]
	assert_false(DirectorLifecycle.restore(activity, director, PROFILE, ACTIVITY, {}, {}, PAIRS.context(pair)).ok)
	assert_eq([activity.serialize(), director.serialize()], before)
	assert_true(director.abort_day(token))
	var replies: Array[bool] = []
	var ctx: Dictionary = PAIRS.context(pair)
	var callback: Callable = func(_day: int) -> void:
		replies.append(DirectorLifecycle.restore(activity, director, PROFILE, ACTIVITY, {}, {}, ctx).ok)
		replies.append(DirectorActivityLifecycle.restore(activity, ACTIVITY, {}, 13).ok)
	activity.activity_changed.connect(callback)
	assert_true(activity.record(3, &"item_purchased", 1).ok)
	activity.activity_changed.disconnect(callback)
	assert_eq(replies, [false, false])
	assert_eq(director.serialize(), before[1])
	assert_eq(activity.serialize().current_counts.item_purchased, 1)

func test_partial_baseline_needs_genuinely_complete_closed_days_and_standalone_restore_is_silent() -> void:
	var activity: DirectorActivityState = DirectorActivityState.new()
	activity.configure(ACTIVITY, 0)
	watch_signals(activity)
	assert_true(DirectorActivityLifecycle.restore(activity, ACTIVITY, {}, 13).ok)
	assert_signal_not_emitted(activity, "activity_changed")
	assert_false(activity.get_window_snapshot().available)
	for day: int in range(14, 21):
		assert_true(activity.advance_day(day).ok)
		assert_false(activity.get_window_snapshot().available)
	assert_true(activity.advance_day(21).ok)
	assert_true(activity.get_window_snapshot().available)
	var raw: Dictionary = activity.serialize()
	assert_true(DirectorActivityLifecycle.restore(activity, ACTIVITY, raw, 21).ok)
	assert_eq(activity.serialize(), raw)
