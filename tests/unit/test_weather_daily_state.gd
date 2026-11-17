extends GutTest
const PROFILE: WeatherProfile = preload("res://data/weather_profile.tres")
var weather: WeatherState

func before_each() -> void:
	weather = WeatherState.new()
	weather.configure(PROFILE,42)

func test_four_field_json_roundtrip_and_legacy_binding_preserve_choices() -> void:
	var raw: Dictionary = {"world_seed":-42.0,"today":"storm","forecast":["storm","rain","cloudy"]}
	weather.configure(PROFILE,0,30)
	weather.deserialize(raw)
	assert_eq(weather.serialize(),{"world_seed":-42,"today":"storm","forecast":["storm","rain","cloudy"],"day_index":30})
	var copy: WeatherState = WeatherState.new()
	copy.configure(PROFILE)
	copy.deserialize(JSON.parse_string(JSON.stringify(weather.serialize())))
	assert_eq(copy.serialize(),weather.serialize())
	assert_false(copy.is_busy())
	assert_eq(copy.serialize().size(),4)

func test_day_decoder_rejects_missing_wrong_unsafe_and_mismatched_day() -> void:
	var raw: Dictionary = weather.serialize()
	for day: Variant in [null,true,"0",-1,1.5,INF,NAN,WeatherSnapshotCodec.MAX_JSON_INTEGER-2]:
		raw.day_index = day
		assert_false(bool(WeatherSnapshotCodec.decode_at_day(PROFILE,raw).ok))
	raw.erase("day_index")
	assert_false(bool(WeatherSnapshotCodec.decode_at_day(PROFILE,raw).ok))
	raw.day_index = 30.0
	assert_true(bool(WeatherSnapshotCodec.decode_at_day(PROFILE,raw,30).ok))
	assert_false(bool(WeatherSnapshotCodec.decode_at_day(PROFILE,raw,29).ok))
	assert_false(bool(WeatherSnapshotCodec.decode_at_day(PROFILE,raw,-2).ok))

func test_invalid_deserialize_retains_owner_and_emits_nothing() -> void:
	watch_signals(weather)
	var before: Dictionary = weather.serialize()
	for raw: Dictionary in [{},{"world_seed":1}, {"world_seed":true,"today":"sunny","forecast":["rain","rain","rain"]}, {"world_seed":0,"today":"sunny","forecast":["rain","rain","rain"],"day_index":-1}]:
		weather.deserialize(raw)
		assert_eq(weather.serialize(),before)
	assert_signal_not_emitted(weather,"weather_changed")
	assert_signal_not_emitted(weather,"forecast_updated")
	weather.configure(Resource.new(),0)
	assert_eq(weather.serialize(),before)

func test_exact_next_day_rejects_duplicate_skip_and_past_without_signals() -> void:
	watch_signals(weather)
	var before: Dictionary = weather.serialize()
	for day: int in [-1,0,2,100]:
		weather.advance_day(day)
		assert_false(bool(weather.day_quote(day).ok))
		assert_eq(weather.serialize(),before)
	assert_signal_not_emitted(weather,"weather_changed")
	weather.advance_day(1)
	assert_eq(weather.today,StringName(before.forecast[0]))
	assert_eq(weather.get_day_index(),1)
	assert_signal_emit_count(weather,"weather_changed",1)
	var after: Dictionary = weather.serialize()
	weather.advance_day(1)
	assert_eq(weather.serialize(),after)
	assert_signal_emit_count(weather,"forecast_updated",1)

func test_opaque_reservation_abort_and_stale_tokens_cannot_commit() -> void:
	var before: Dictionary = weather.serialize()
	var reserved: Dictionary = weather.begin_day(1)
	assert_true(bool(reserved.ok))
	assert_true(weather.is_busy())
	assert_eq(weather.serialize(),before)
	assert_false(weather.finish_day(null))
	assert_false(weather.abort_day(RefCounted.new()))
	assert_false(bool(weather.begin_day(1).ok))
	assert_true(weather.abort_day(reserved.token))
	assert_false(weather.is_busy())
	assert_eq(weather.serialize(),before)
	var retry: Dictionary = weather.begin_day(1)
	assert_false(weather.finish_day(reserved.token))
	assert_true(weather.finish_day(retry.token))
	assert_false(weather.finish_day(retry.token))
	assert_false(weather.abort_day(retry.token))
	assert_eq(weather.get_day_index(),1)

func test_captured_terms_survive_public_mutation_and_replacement_attempts() -> void:
	var before: Dictionary = weather.serialize()
	var pending: Dictionary = weather.begin_day(1)
	weather.configure(PROFILE,-42,99)
	weather.deserialize({})
	weather.force_weather(&"storm")
	assert_false(bool(weather.restore_for_day({},99).ok))
	weather.world_seed = -99
	weather.today = &"storm"
	weather.forecast.clear()
	assert_true(weather.finish_day(pending.token))
	assert_eq(weather.world_seed,42)
	assert_eq(weather.today,StringName(before.forecast[0]))
	assert_eq(weather.forecast,[StringName(before.forecast[1]),StringName(before.forecast[2]),WeatherRoller.roll_day(PROFILE,42,4)])
	assert_eq(weather.get_day_index(),1)

func test_notifications_remain_busy_and_arrays_are_detached() -> void:
	var attempts: Array[bool] = []
	var on_weather: Callable = func(_id: StringName) -> void:
		attempts.append(weather.is_busy())
		attempts.append(bool(weather.begin_day(2).ok))
		weather.force_weather(&"storm")
		weather.configure(PROFILE,99)
	var local: Callable = func(values: Array[StringName]) -> void: values.clear()
	var global: Callable = func(values: Array[StringName]) -> void: values[0] = &"storm"
	weather.weather_changed.connect(on_weather)
	weather.forecast_updated.connect(local)
	Events.forecast_updated.connect(global)
	var expected: StringName = weather.forecast[0]
	weather.advance_day(1)
	Events.forecast_updated.disconnect(global)
	assert_eq(attempts,[true,false])
	assert_eq(weather.today,expected)
	assert_eq(weather.world_seed,42)
	assert_eq(weather.forecast.size(),3)
	assert_eq(weather.forecast[0],WeatherRoller.roll_day(PROFILE,42,2))
	assert_false(weather.is_busy())

func test_explicit_load_preserves_saved_zero_weight_choices_or_uses_correct_day_baseline() -> void:
	var profile: WeatherProfile = PROFILE.duplicate(true) as WeatherProfile
	profile.entries[3].probability = 0
	weather.configure(profile)
	var raw: Dictionary = {"world_seed":-42,"today":"storm","forecast":["storm","storm","storm"]}
	assert_eq(weather.restore_for_day(raw,30).reason,&"restored")
	assert_eq(weather.today,&"storm")
	assert_eq(weather.forecast,[&"storm",&"storm",&"storm"])
	assert_eq(weather.get_day_index(),30)
	assert_true(bool(weather.restore_for_day([],99).used_fallback))
	assert_eq(weather.serialize(),WeatherRoller.initial_snapshot(profile,0,99))
	assert_true(bool(weather.restore_for_day({},30).used_fallback))
	assert_eq(weather.serialize(),WeatherRoller.initial_snapshot(profile,0,30))
	var before: Dictionary = weather.serialize()
	assert_false(bool(weather.restore_for_day(before,-1).ok))
	assert_eq(weather.serialize(),before)
	assert_eq(WeatherSaveCodec.normalize(profile,before,-1),{})

func test_last_json_safe_day_fails_preflight_without_overflow_or_draw() -> void:
	weather.configure(PROFILE,0,WeatherSnapshotCodec.MAX_JSON_INTEGER-3)
	var before: Dictionary = weather.serialize()
	assert_false(bool(weather.begin_day(weather.get_day_index()+1).ok))
	assert_eq(weather.serialize(),before)
	assert_false(weather.is_busy())

func test_thousand_days_match_cold_restores_and_preserve_each_prerolled_head() -> void:
	var resumed: WeatherState = WeatherState.new()
	resumed.configure(PROFILE,0)
	resumed.deserialize(weather.serialize())
	for day: int in range(1,1001):
		var expected: StringName = weather.forecast[0]
		weather.advance_day(day)
		resumed.advance_day(day)
		assert_eq(weather.today,expected)
		assert_eq(weather.get_day_index(),day)
		assert_eq(weather.forecast.size(),PROFILE.forecast_days)
		assert_eq(weather.forecast.back(),WeatherRoller.roll_day(PROFILE,42,day+PROFILE.forecast_days))
		assert_eq(resumed.serialize(),weather.serialize())
		if day%50==0:
			resumed = WeatherState.new()
			resumed.configure(PROFILE,-42)
			resumed.deserialize(JSON.parse_string(JSON.stringify(weather.serialize())))
