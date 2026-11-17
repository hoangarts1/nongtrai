extends GutTest
const PROFILE: WeatherProfile = preload("res://data/weather_profile.tres")
const GOLDEN: String = "res://tests/fixtures/weather_rng_v12.json"

func test_pinned_actual_rng_vectors_include_signed_large_seeds_and_merchant_stream() -> void:
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	assert_eq(saved.engine,Engine.get_version_info().string)
	assert_eq(int(saved.weather_tag),DetRandom.TAG_WEATHER)
	assert_eq(int(saved.merchant_tag),DetRandom.TAG_MERCHANT)
	assert_eq(saved.vectors.size(),30)
	for row: Dictionary in saved.vectors:
		assert_eq(String(WeatherRoller.roll_day(PROFILE,int(row.seed),int(row.day))),row.weather)
		var merchant: RandomNumberGenerator = DetRandom.make_rng(int(row.seed),int(row.day),DetRandom.TAG_MERCHANT)
		for expected: float in row.merchant_u32:
			assert_eq(merchant.randi(),int(expected))

func test_weight_selection_matches_documented_tagged_integer_draw() -> void:
	for seed: int in [-42,0,42]:
		for day: int in range(40):
			var rng: RandomNumberGenerator = DetRandom.make_rng(seed,day,DetRandom.TAG_WEATHER)
			var draw: int = rng.randi_range(0,99)
			var expected: StringName = &""
			for entry: Dictionary in PROFILE.entries:
				draw -= int(entry.probability)
				if draw<0:
					expected = StringName(entry.id)
					break
			assert_eq(WeatherRoller.roll_day(PROFILE,seed,day),expected)

func test_weather_draws_never_consume_or_change_existing_merchant_rng() -> void:
	var control: RandomNumberGenerator = DetRandom.make_rng(-42,30,DetRandom.TAG_MERCHANT)
	var merchant: RandomNumberGenerator = DetRandom.make_rng(-42,30,DetRandom.TAG_MERCHANT)
	for day: int in range(100):
		WeatherRoller.roll_day(PROFILE,-42,day)
		assert_eq(merchant.randi(),control.randi())

func test_profile_horizon_initial_id_and_zero_weights_drive_draws() -> void:
	var profile: WeatherProfile = PROFILE.duplicate(true) as WeatherProfile
	profile.forecast_days = 1
	profile.initial_weather_id = &"storm"
	for entry: Dictionary in profile.entries:
		entry.probability = 1 if entry.id==&"rain" else 0
	assert_eq(WeatherRoller.initial_snapshot(profile,42,30),{"world_seed":42,"today":"storm","forecast":["rain"],"day_index":30})
	for day: int in range(25):
		assert_eq(WeatherRoller.roll_day(profile,42,day),&"rain")
	profile.initial_weather_id = &"missing"
	assert_false(profile.validation_errors().is_empty())
	assert_eq(WeatherRoller.initial_snapshot(profile,42,0),{})

func test_invalid_numeric_context_or_profile_has_no_partial_snapshot() -> void:
	assert_eq(WeatherRoller.initial_snapshot(null,0,0),{})
	for seed: int in [WeatherSnapshotCodec.MAX_JSON_INTEGER+1,-WeatherSnapshotCodec.MAX_JSON_INTEGER-1]:
		assert_eq(WeatherRoller.roll_day(PROFILE,seed,0),&"")
		assert_eq(WeatherRoller.initial_snapshot(PROFILE,seed,0),{})
	for day: int in [-1,WeatherSnapshotCodec.MAX_JSON_INTEGER-2,WeatherSnapshotCodec.MAX_JSON_INTEGER]:
		assert_eq(WeatherRoller.initial_snapshot(PROFILE,0,day),{})
	assert_eq(WeatherRoller.roll_day(PROFILE,0,-1),&"")
