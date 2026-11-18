extends GutTest

const SHIPPED: EcologyFeedbackProfile = preload("res://data/ecology_feedback_profile.tres")
const ECOLOGY: EcologyProfile = preload("res://data/ecology_profile.tres")

func test_shipped_limits_definitions_and_validator_are_presentation_only() -> void:
	assert_eq(DataValidator.validate_ecology_feedback(SHIPPED, ECOLOGY), PackedStringArray())
	assert_eq(SHIPPED.total_cap, 14)
	assert_eq(SHIPPED.effects[0].count, 8)
	assert_eq(SHIPPED.effects[1].count, 6)
	assert_false(DataValidator.validate_ecology_feedback(null, ECOLOGY).is_empty())
	assert_false(DataValidator.validate_ecology_feedback(SHIPPED, null).is_empty())
	for row: Dictionary in SHIPPED.effects:
		assert_eq(row.anchors.size(), row.count)
		assert_true(row.body is PackedVector2Array)
		assert_false(row.has("path"), "Historical 3D scenes are not dependencies")

func test_bad_caps_motion_anchors_geometry_and_colors_are_rejected_without_source_changes() -> void:
	var source: Array[Dictionary] = SHIPPED.effects.duplicate(true)
	for field: String in ["total_cap", "refresh_seconds", "night_sun_energy", "night_opacity", "rain_opacity"]:
		var profile: EcologyFeedbackProfile = _copy()
		profile.set(field, 0 if field == "total_cap" else NAN)
		assert_false(profile.validation_errors(ECOLOGY).is_empty(), field)
	for mutation: Dictionary in [{"count": 15}, {"count": true}, {"anchors": PackedFloat32Array()}, {"anchors": PackedFloat32Array([NAN])}, {"body": PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])}, {"wing": PackedVector2Array([Vector2.INF, Vector2.ONE, Vector2.ZERO])}, {"body_color": Color(NAN, 0, 0)}, {"speed": INF}, {"altitude": -1.0}, {"span": Vector2(-1, 0)}]:
		var profile: EcologyFeedbackProfile = _copy()
		profile.effects[0].merge(mutation, true)
		assert_false(profile.validation_errors(ECOLOGY).is_empty(), str(mutation))
	assert_eq(SHIPPED.effects, source)

func test_water_unknown_duplicate_and_wrong_threshold_bindings_are_rejected() -> void:
	for mutation: Dictionary in [{"id": "fish"}, {"metric_id": "water_clarity"}, {"threshold_id": "birds"}, {"id": "birds", "metric_id": "tree_cover", "threshold_id": "birds"}]:
		var profile: EcologyFeedbackProfile = _copy()
		profile.effects[0].merge(mutation, true)
		assert_false(profile.validation_errors(ECOLOGY).is_empty())
	var profile: EcologyFeedbackProfile = _copy()
	profile.effects.pop_back()
	assert_false(profile.validation_errors(ECOLOGY).is_empty())
	assert_eq(SHIPPED.validation_errors(ECOLOGY), PackedStringArray())

func _copy() -> EcologyFeedbackProfile:
	var profile: EcologyFeedbackProfile = SHIPPED.duplicate(true) as EcologyFeedbackProfile
	profile.effects = SHIPPED.effects.duplicate(true)
	return profile
