extends GutTest

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const CONFIG: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
var _crops: Array[Resource] = []
var _regions: Array[Rect2i] = []
var _state: EcologyState

func before_each() -> void:
	_crops = DataRegistry.get_all_crops()
	_regions = [Rect2i(0, 0, 6, 6)]
	_state = EcologyState.new()
	assert_true(_state.configure(PROFILE))

func _row(id: String, x: int, growth: int = 0, target: int = 4, repeating: bool = false, dead: bool = false) -> Dictionary:
	return {"cell_x": x, "cell_y": 0, "crop_id": id, "tilled": true, "growth_days": growth, "growth_target": target, "regrowing": repeating, "watered": false, "consecutive_dry_days": 0, "withered": dead, "withered_days": 1 if dead else 0}

func _restore(raw: Variant, farm: Variant, day: int = 30) -> Dictionary:
	return EcologyLifecycle.restore(_state, PROFILE, CONFIG, raw, day, farm, _crops, _regions)

func test_current_garden_baseline_counts_maturity_alias_regrow_dead_and_unowned() -> void:
	var farm: Dictionary = {"plots": [_row("orange", 0, 3, 4), _row("apple", 1, 4, 4), _row("banana", 2, 0, 2, true), _row("carrot", 3), _row("spring_carrot", 4), _row("coffee", 5, 10, 10, false, true), _row("pepper", 9)]}
	var result: Dictionary = _restore({}, farm)
	assert_true(result.ok)
	assert_eq(result.reason, &"calibrated_missing_or_invalid")
	assert_eq(result.sample.counts, {"mature_fruit_trees": 2, "healthy_plants": 5, "species": 4})
	assert_eq(_state.get_metrics(), {"tree_cover": 25.0, "water_clarity": 0.0, "biodiversity": 50.0})
	assert_eq(_state.get_day_index(), 30)
	assert_eq(_state.get_triggered(), PackedStringArray(), "No invented historical crossing")
	assert_true(_state.is_threshold_active(&"butterflies"))
	assert_false(result.sample.available.water_clarity)

func test_valid_saved_values_history_and_water_are_retained_silently() -> void:
	var saved: Dictionary = {"day_index": 30, "metrics": {"tree_cover": 29.99, "water_clarity": 42.125, "biodiversity": 12.5}, "triggered": ["birds"]}
	watch_signals(_state)
	var result: Dictionary = _restore(saved, {"plots": []})
	assert_true(result.ok)
	assert_eq(result.reason, &"restored")
	assert_eq(_state.serialize(), saved)
	assert_eq(result.sample.targets.water_clarity, 42.125)
	assert_false(result.sample.available.water_clarity)
	assert_signal_not_emitted(_state, "ecology_changed")
	assert_signal_not_emitted(_state, "threshold_crossed")

func test_corrupt_missing_and_wrong_day_calibrate_without_advancing_past_days() -> void:
	watch_signals(_state)
	for raw: Variant in [null, {}, [], {"day_index": 29, "metrics": {"tree_cover": 100, "water_clarity": 100, "biodiversity": 100}, "triggered": []}, {"day_index": 30, "metrics": {"tree_cover": NAN}, "triggered": []}]:
		var result: Dictionary = _restore(raw, {"plots": []})
		assert_true(result.ok)
		assert_ne(result.reason, &"restored")
		assert_eq(_state.get_day_index(), 30)
		assert_eq(_state.get_metrics().tree_cover, 0.0)
		assert_eq(_state.get_triggered(), PackedStringArray())
	assert_signal_not_emitted(_state, "ecology_changed")
	assert_signal_not_emitted(_state, "threshold_crossed")

func test_invalid_farm_config_profile_and_day_leave_existing_owner_exact() -> void:
	assert_true(_restore({}, {"plots": [_row("orange", 0, 4)]}).ok)
	var before: Dictionary = _state.serialize()
	for farm: Variant in [null, {}, {"plots": [_row("unknown", 0)]}, {"plots": [_row("apple", 0), _row("apple", 0)]}]:
		assert_false(_restore({}, farm).ok)
		assert_eq(_state.serialize(), before)
	assert_false(_restore({}, {"plots": []}, -1).ok)
	assert_eq(_state.serialize(), before)
	assert_false(EcologyLifecycle.restore(_state, null, CONFIG, {}, 30, {"plots": []}, _crops, _regions).ok)
	assert_false(EcologyLifecycle.restore(_state, PROFILE, null, {}, 30, {"plots": []}, _crops, _regions).ok)
	assert_eq(_state.serialize(), before)

func test_explicit_new_game_resets_same_owner_without_rewards_or_signals() -> void:
	assert_true(_restore({"day_index": 30, "metrics": {"tree_cover": 100, "water_clarity": 50, "biodiversity": 100}, "triggered": ["birds", "butterflies"]}, {"plots": []}).ok)
	watch_signals(_state)
	assert_true(_restore({}, {"plots": []}, 0).ok)
	assert_eq(_state.get_metrics(), {"tree_cover": 0.0, "water_clarity": 0.0, "biodiversity": 0.0})
	assert_eq(_state.get_day_index(), 0)
	assert_eq(_state.get_triggered(), PackedStringArray())
	assert_signal_not_emitted(_state, "ecology_changed")
	assert_signal_not_emitted(_state, "threshold_crossed")

func test_daily_sampling_eases_once_and_holds_unmeasured_saved_water() -> void:
	var raw: Dictionary = {"day_index": 30, "metrics": {"tree_cover": 100.0, "water_clarity": 33.5, "biodiversity": 100.0}, "triggered": []}
	assert_true(_restore(raw, {"plots": []}).ok)
	var result: Dictionary = EcologyLifecycle.advance(_state, CONFIG, 31, {"plots": []}, _crops, _regions)
	assert_true(result.ok)
	assert_eq(_state.get_metrics(), {"tree_cover": 90.0, "water_clarity": 33.5, "biodiversity": 90.0})
	var before: Dictionary = _state.serialize()
	for day: int in [31, 33, -1]:
		assert_false(EcologyLifecycle.advance(_state, CONFIG, day, {"plots": []}, _crops, _regions).ok)
		assert_eq(_state.serialize(), before)
	assert_false(EcologyLifecycle.advance(_state, CONFIG, 32, {}, _crops, _regions).ok)
	assert_eq(_state.serialize(), before)

func test_reentrant_restore_and_sampled_advance_are_blocked_during_notifications() -> void:
	assert_true(_restore({}, {"plots": []}, 0).ok)
	var calls: Array[int] = [0]
	_state.ecology_changed.connect(func(_metrics: Dictionary) -> void:
		calls[0] += 1
		assert_false(_restore({}, {"plots": []}, 0).ok)
		assert_false(EcologyLifecycle.advance(_state, CONFIG, 2, {"plots": []}, _crops, _regions).ok)
	)
	assert_true(EcologyLifecycle.advance(_state, CONFIG, 1, {"plots": [_row("orange", 0, 4)]}, _crops, _regions).ok)
	assert_eq(calls[0], 1)
	assert_eq(_state.get_day_index(), 1)
	assert_eq(_state.get_metrics().tree_cover, 1.25)

func test_calibration_uses_configured_initial_water_and_detaches_all_results() -> void:
	var profile: EcologyProfile = EcologyProfile.new()
	for resource: Resource in PROFILE.metrics:
		var metric: EcologyMetricData = resource.duplicate(true) as EcologyMetricData
		metric.thresholds = (resource as EcologyMetricData).thresholds.duplicate(true)
		if metric.metric_id == &"water_clarity":
			metric.initial_value = 17.25
		profile.metrics.append(metric)
	var farm: Dictionary = {"plots": [_row("orange", 0, 4)]}
	var before: Dictionary = farm.duplicate(true)
	var result: Dictionary = EcologyLifecycle.restore(_state, profile, CONFIG, {}, 5, farm, _crops, _regions)
	assert_true(result.ok)
	assert_eq(_state.get_metrics().water_clarity, 17.25)
	result.snapshot.metrics.tree_cover = 999
	result.sample.counts.species = 999
	result.sample.available.water_clarity = true
	assert_eq(_state.get_metrics().tree_cover, 12.5)
	assert_eq(farm, before)
	assert_false(EcologyLifecycle.resolve(PROFILE, CONFIG, {}, -1, farm, _crops, _regions).ok)
