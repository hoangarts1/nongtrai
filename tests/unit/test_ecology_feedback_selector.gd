extends GutTest

const PROFILE: EcologyFeedbackProfile = preload("res://data/ecology_feedback_profile.tres")
const ECOLOGY: EcologyProfile = preload("res://data/ecology_profile.tres")
const AVAILABLE: Dictionary = {"tree_cover": true, "biodiversity": true, "water_clarity": false}

func test_below_equal_above_and_downward_values_use_current_levels_without_history() -> void:
	for values: Array in [[29.0, 24.0, 0], [30.0, 24.0, 6], [29.0, 25.0, 8], [30.0, 25.0, 14], [100.0, 100.0, 14], [0.0, 0.0, 0]]:
		var metrics: Dictionary = {"tree_cover": values[0], "biodiversity": values[1], "water_clarity": 100.0}
		var result: Dictionary = EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, AVAILABLE)
		assert_true(result.ok)
		assert_eq(result.total, int(values[2]))
		assert_true(result.total <= PROFILE.total_cap)
		assert_eq(result, EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, AVAILABLE))

func test_silent_restoration_and_stale_history_never_activate_below_threshold_effects() -> void:
	var state: EcologyState = EcologyState.new()
	assert_true(state.configure(ECOLOGY))
	assert_true(state.deserialize({"day_index": 999, "metrics": {"tree_cover": 0, "biodiversity": 0, "water_clarity": 100}, "triggered": ["birds", "butterflies", "clear_water"]}))
	var before: Dictionary = state.serialize()
	var result: Dictionary = EcologyFeedbackSelector.select(PROFILE, ECOLOGY, state.get_metrics(), AVAILABLE)
	assert_eq(result.total, 0)
	assert_eq(state.serialize(), before)
	assert_true(state.deserialize({"day_index": 999, "metrics": {"tree_cover": 30, "biodiversity": 25, "water_clarity": 0}, "triggered": []}))
	assert_eq(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, state.get_metrics(), AVAILABLE).total, 14)

func test_unavailable_invalid_and_detached_outputs_have_no_side_effects_or_fake_water() -> void:
	var metrics: Dictionary = {"tree_cover": 100.0, "biodiversity": 100.0, "water_clarity": 100.0}
	var available: Dictionary = AVAILABLE.duplicate()
	available.tree_cover = false
	assert_eq(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, available).total, 8)
	available.biodiversity = false
	assert_eq(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, available).total, 0)
	available.water_clarity = true
	assert_false(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, available).ok)
	assert_false(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, {"tree_cover": NAN}, AVAILABLE).ok)
	assert_false(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, {}).ok)
	var result: Dictionary = EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, AVAILABLE)
	result.effects[0].anchors[0] = -10.0
	result.effects[0].count = 999
	assert_eq(PROFILE.effects[0].count, 8)
	assert_eq(EcologyFeedbackSelector.select(PROFILE, ECOLOGY, metrics, AVAILABLE).total, 14)
