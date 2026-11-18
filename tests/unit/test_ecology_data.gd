extends GutTest

const SHIPPED: EcologyProfile = preload("res://data/ecology_profile.tres")
var profile: EcologyProfile

func before_each() -> void:
	profile = EcologyProfile.new()
	for resource: Resource in SHIPPED.metrics:
		var source: EcologyMetricData = resource as EcologyMetricData
		var copy: EcologyMetricData = source.duplicate(true) as EcologyMetricData
		copy.thresholds = source.thresholds.duplicate(true)
		profile.metrics.append(copy)

func test_shipped_profile_matches_approved_three_metrics_and_master_thresholds() -> void:
	assert_eq(DataValidator.validate_ecology_profile(SHIPPED), PackedStringArray())
	assert_eq(SHIPPED.metrics.size(), 3)
	var expected: Dictionary = {"tree_cover": 30.0, "water_clarity": 50.0, "biodiversity": 25.0}
	for resource: Resource in SHIPPED.metrics:
		var metric: EcologyMetricData = resource as EcologyMetricData
		assert_true(expected.has(String(metric.metric_id)))
		assert_eq(metric.minimum, 0.0)
		assert_eq(metric.maximum, 100.0)
		assert_eq(metric.initial_value, 0.0)
		assert_eq(metric.ease_percent, 10.0)
		assert_eq(metric.thresholds[0].value, expected[String(metric.metric_id)])
	assert_null(profile.get_metric(&"unknown"))
	var rows: Array[Dictionary] = profile.get_thresholds()
	rows[0].value = -999.0
	assert_eq(profile.get_thresholds()[0].value, 30.0, "Threshold enumeration is detached")

func test_null_empty_wrong_resource_and_duplicate_ids_are_rejected() -> void:
	assert_false(DataValidator.validate_ecology_profile(null).is_empty())
	assert_false(DataValidator.validate_ecology_profile(EcologyProfile.new()).is_empty())
	profile.metrics.append(null)
	assert_false(profile.validation_errors().is_empty())
	profile.metrics.pop_back()
	profile.metrics.append(Resource.new())
	assert_false(profile.validation_errors().is_empty())
	profile.metrics.pop_back()
	profile.metrics.append(profile.metrics[0])
	assert_false(profile.validation_errors().is_empty())
	profile.metrics.pop_back()
	(profile.metrics[1] as EcologyMetricData).thresholds[0].id = &"birds"
	assert_false(profile.validation_errors().is_empty(), "Cross-metric threshold duplicates are ambiguous")
	assert_eq(profile.get_thresholds(), [])

func test_bad_metric_bounds_initial_and_ease_never_pass_validation() -> void:
	var metric: EcologyMetricData = profile.metrics[0] as EcologyMetricData
	for value: float in [NAN, INF, -1.0, 0.0, 100.001]:
		metric.ease_percent = value
		assert_false(metric.validation_errors().is_empty())
	metric.ease_percent = 100.0
	assert_eq(metric.validation_errors(), PackedStringArray(), "A test profile may use exact direct movement")
	metric.initial_value = 101.0
	assert_false(metric.validation_errors().is_empty())
	metric.initial_value = 0.0
	metric.maximum = metric.minimum
	assert_false(metric.validation_errors().is_empty())
	metric.maximum = 100.0
	metric.minimum = NAN
	assert_false(metric.validation_errors().is_empty())

func test_malformed_threshold_values_ids_and_missing_fields_are_rejected() -> void:
	var metric: EcologyMetricData = profile.metrics[0] as EcologyMetricData
	for value: Variant in [true, "30", null, NAN, INF, -0.1, 100.1]:
		metric.thresholds[0].value = value
		assert_false(metric.validation_errors().is_empty())
	metric.thresholds = [{"id": &"birds", "value": 30.0}, {"id": &"birds", "value": 40.0}]
	assert_false(metric.validation_errors().is_empty())
	for id: Variant in ["", "Bad-ID", 7, true, null, "_bad", "double__underscore"]:
		metric.thresholds = [{"id": id, "value": 30.0}]
		assert_false(metric.validation_errors().is_empty())
	metric.thresholds = [{}]
	assert_false(metric.validation_errors().is_empty())
	assert_eq(SHIPPED.validation_errors(), PackedStringArray(), "Bad clones never change shipped data")
