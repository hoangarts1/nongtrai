extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const LOCALES: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]

func test_null_missing_context_unknown_duplicate_and_wrong_class_definitions_fail() -> void:
	assert_false(DataValidator.validate_director_profile(null, LOCALES).is_empty())
	assert_false(DirectorProfile.new().validation_errors().is_empty())
	var copy: DirectorProfile = PROFILE.frozen_copy()
	copy.events.append(copy.events[0])
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.events[0] = Resource.new()
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").id = &"made_up"
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.seasons.pop_back()
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.seasons.reverse()
	assert_false(copy.validation_errors().is_empty())

func test_nonfinite_weights_bad_days_caps_and_missing_translation_are_rejected() -> void:
	for field: String in ["grace_days", "pity_days", "max_negative_per_season", "min_negative_gap", "history_limit"]:
		var copy: DirectorProfile = PROFILE.frozen_copy()
		copy.set(field, 0)
		assert_false(copy.validation_errors().is_empty(), field)
	for value: float in [NAN, INF, -1.0]:
		var copy: DirectorProfile = PROFILE.frozen_copy()
		copy.get_event(&"gentle_dust").weight = value
		assert_false(copy.validation_errors().is_empty())
	for field: String in ["duration_days", "cooldown_days", "max_per_season", "telegraph_days"]:
		var copy: DirectorProfile = PROFILE.frozen_copy()
		copy.get_event(&"gentle_dust").set(field, 0)
		assert_false(copy.validation_errors().is_empty(), field)
	var copy: DirectorProfile = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").counter_hint_key = &"DIR_MISSING_TRANSLATION"
	assert_false(DataValidator.validate_director_profile(copy, LOCALES).is_empty())

func test_unmeasured_water_unknown_threshold_and_wrong_typed_children_are_rejected() -> void:
	var copy: DirectorProfile = PROFILE.frozen_copy()
	var condition: DirectorConditionData = copy.get_event(&"butterfly_bloom").conditions[0] as DirectorConditionData
	condition.metric_id = &"water_clarity"
	condition.threshold_id = &"clear_water"
	assert_false(copy.validation_errors().is_empty())
	condition.metric_id = &"tree_cover"
	condition.threshold_id = &"butterflies"
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").effects = [Resource.new()]
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").conditions = [null]
	assert_false(copy.validation_errors().is_empty())

func test_effect_references_counter_bounds_and_prototype_bindings_fail_atomically() -> void:
	for field: String in ["npc_id", "location_id"]:
		var copy: DirectorProfile = PROFILE.frozen_copy()
		copy.get_event(&"merchant_visit").effects[0].set(field, &"missing")
		assert_false(copy.validation_errors().is_empty())
	var copy: DirectorProfile = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").effects[0].extra_charge = -1
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.get_event(&"gentle_dust").is_negative = false
	assert_false(copy.validation_errors().is_empty())
	copy = PROFILE.frozen_copy()
	copy.get_event(&"butterfly_bloom").effects[0].accent_color = Color(NAN, 1, 1, 1)
	assert_false(copy.validation_errors().is_empty())
	assert_eq(PROFILE.validation_errors(), PackedStringArray())
