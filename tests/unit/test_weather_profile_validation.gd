extends GutTest
const SHIPPED: WeatherProfile = preload("res://data/weather_profile.tres")
var profile: WeatherProfile

func before_each() -> void:
	profile = SHIPPED.duplicate(true) as WeatherProfile

func test_actual_data_horizon_weights_flags_and_existing_lookup_are_preserved() -> void:
	assert_eq(SHIPPED.forecast_days,3)
	assert_eq(SHIPPED.entries.size(),4)
	assert_eq(SHIPPED.validation_errors(),PackedStringArray())
	assert_eq(profile.entries,[{"id":&"sunny","probability":55,"darkness":0.0,"rain":false,"storm":false},{"id":&"cloudy","probability":25,"darkness":0.12,"rain":false,"storm":false},{"id":&"rain","probability":15,"darkness":0.24,"rain":true,"storm":false},{"id":&"storm","probability":5,"darkness":0.34,"rain":true,"storm":true}])
	assert_eq(profile.get_entry(&"rain"),profile.entries[2])
	assert_eq(profile.get_entry(&"missing_weather"),{})

func test_existing_path_facade_and_new_resource_facade_have_safe_failures() -> void:
	assert_eq(DataValidator.validate_weather_profile("res://data/weather_profile.tres"),PackedStringArray())
	assert_eq(DataValidator.validate_weather_resource(profile),PackedStringArray())
	assert_false(DataValidator.validate_weather_resource(null).is_empty())
	assert_string_contains("\n".join(DataValidator.validate_weather_profile("res://data/no_weather_fixture_here.tres")),"missing")
	assert_string_contains("\n".join(DataValidator.validate_weather_profile("res://data/items/egg.tres")),"requires WeatherProfile")

func test_nonpositive_unsafe_horizon_and_empty_entries_reject() -> void:
	for days: int in [0,-1,2147483648]:
		profile.forecast_days = days
		assert_string_contains("\n".join(profile.validation_errors()),"horizon")
	profile.forecast_days = 3
	profile.entries.clear()
	assert_string_contains("\n".join(profile.validation_errors()),"must not be empty")

func test_weather_ids_require_real_ascii_snake_case_strings() -> void:
	for id: Variant in [null,true,42,"","Rain","bad-id","bad__id","bad_","mưa"]:
		profile.entries[0]["id"] = id
		assert_string_contains("\n".join(profile.validation_errors()),"invalid snake_case")

func test_duplicate_ids_reject_even_across_string_and_string_name() -> void:
	profile.entries[1]["id"] = "sunny"
	assert_string_contains("\n".join(profile.validation_errors()),"duplicate weather id")

func test_probability_types_bounds_positive_total_and_overflow_are_checked() -> void:
	for value: Variant in [null,true,"55",55.0,-1,2147483648,INF]:
		profile.entries[0]["probability"] = value
		assert_string_contains("\n".join(profile.validation_errors()),"probability")
	for index: int in range(profile.entries.size()):
		profile.entries[index]["probability"] = 0
	assert_string_contains("\n".join(profile.validation_errors()),"positive total")
	profile.entries[0]["probability"] = WeatherProfile.MAX_WEIGHT_TOTAL
	profile.entries[1]["probability"] = 1
	assert_string_contains("\n".join(profile.validation_errors()),"total exceeds safe bound")
	profile.entries[0]["probability"] = 0
	assert_eq(profile.validation_errors(),PackedStringArray(),"Zero weight is valid while another weight is positive")

func test_darkness_requires_finite_unit_interval_without_boolean_coercion() -> void:
	for value: Variant in [null,true,"0",-0.01,1.01,NAN,INF,-INF]:
		profile.entries[0]["darkness"] = value
		assert_string_contains("\n".join(profile.validation_errors()),"darkness")
	for value: Variant in [0,1,0.5]:
		profile.entries[0]["darkness"] = value
		assert_eq(profile.validation_errors(),PackedStringArray())

func test_flags_are_booleans_and_storm_requires_rain() -> void:
	for key: String in ["rain","storm"]:
		for value: Variant in [null,0,1,"false"]:
			profile = SHIPPED.duplicate(true) as WeatherProfile
			profile.entries[0][key] = value
			assert_string_contains("\n".join(profile.validation_errors()),"booleans")
	profile = SHIPPED.duplicate(true) as WeatherProfile
	profile.entries[0]["storm"] = true
	assert_string_contains("\n".join(profile.validation_errors()),"storm requires rain")
	profile.entries[0]["rain"] = true
	assert_eq(profile.validation_errors(),PackedStringArray())

func test_repeated_validation_does_not_mutate_any_profile_values() -> void:
	var before: String = var_to_str(profile.entries)
	for _index: int in range(5):
		assert_eq(profile.validation_errors(),PackedStringArray())
		assert_eq(DataValidator.validate_weather_resource(profile),PackedStringArray())
	assert_eq(var_to_str(profile.entries),before)
	assert_eq(profile.forecast_days,3)
	assert_eq(SHIPPED.validation_errors(),PackedStringArray())
