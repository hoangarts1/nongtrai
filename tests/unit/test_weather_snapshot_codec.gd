extends GutTest
const SHIPPED: WeatherProfile = preload("res://data/weather_profile.tres")
const FIXTURE: String = "res://tests/fixtures/weather_snapshot_v11.json"
var profile: WeatherProfile
var payload: Dictionary

func before_each() -> void:
	profile = SHIPPED.duplicate(true) as WeatherProfile
	payload = {"world_seed":0,"today":"sunny","forecast":["cloudy","rain","sunny"]}

func _decode() -> Dictionary:
	return WeatherSnapshotCodec.decode(profile,payload)

func _rejected(raw: Variant) -> void:
	var result: Dictionary = WeatherSnapshotCodec.decode(profile,raw)
	assert_false(bool(result.ok))
	assert_false(result.has("snapshot"),"No partial/fabricated snapshot on failure")
	assert_false((result.errors as PackedStringArray).is_empty())

func test_fixture_is_actual_existing_v11_component_and_canonical_wire() -> void:
	var fixture: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var save: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v11.json"))
	assert_eq(fixture,save.weather,"Codec fixture is not an invented RNG golden")
	var result: Dictionary = WeatherSnapshotCodec.decode(profile,fixture)
	assert_true(bool(result.ok))
	assert_eq(result.snapshot,payload)
	assert_true(result.snapshot.world_seed is int)
	assert_true(result.snapshot.today is String)
	for id: Variant in result.snapshot.forecast:
		assert_true(id is String)
	assert_eq(result.snapshot.size(),3)

func test_valid_existing_weather_state_samples_roundtrip_without_changing_choices() -> void:
	for seed: int in [0,42,-42]:
		var old: WeatherState = WeatherState.new()
		old.configure(SHIPPED,seed)
		var wire: Dictionary = old.serialize()
		wire.erase("day_index") # Keep this fixture in the legacy three-field format.
		var decoded: Dictionary = WeatherSnapshotCodec.decode(profile,wire)
		assert_true(bool(decoded.ok))
		assert_eq(decoded.snapshot,wire)
		var restored: WeatherState = WeatherState.new()
		restored.configure(SHIPPED,999)
		restored.deserialize(decoded.snapshot)
		var restored_wire: Dictionary = restored.serialize()
		assert_eq(int(restored_wire.day_index),0)
		restored_wire.erase("day_index")
		assert_eq(restored_wire,wire)

func test_signed_seeds_and_integral_json_numbers_preserve_exact_values() -> void:
	for value: int in [0,42,-42,WeatherSnapshotCodec.MAX_JSON_INTEGER,-WeatherSnapshotCodec.MAX_JSON_INTEGER]:
		for encoded: Variant in [value,float(value)]:
			payload.world_seed = encoded
			var result: Dictionary = _decode()
			assert_true(bool(result.ok))
			assert_true(result.snapshot.world_seed is int)
			assert_eq(int(result.snapshot.world_seed),value)
			assert_eq(result.snapshot.forecast,payload.forecast)

func test_invalid_seed_types_nonfinite_fractions_and_unsafe_values_reject() -> void:
	for value: Variant in [null,true,false,"0",0.25,NAN,INF,-INF,[],{},profile,WeatherSnapshotCodec.MAX_JSON_INTEGER+1,-WeatherSnapshotCodec.MAX_JSON_INTEGER-1,9223372036854775807,-9223372036854775807-1]:
		payload.world_seed = value
		var before: String = var_to_str(payload)
		_rejected(payload)
		assert_eq(var_to_str(payload),before)

func test_missing_fields_and_wrong_root_containers_never_fabricate_defaults() -> void:
	for key: String in ["world_seed","today","forecast"]:
		var partial: Dictionary = payload.duplicate(true)
		partial.erase(key)
		_rejected(partial)
	for raw: Variant in [null,true,0,"sunny",[],PackedStringArray(["sunny"])]:
		_rejected(raw)

func test_invalid_today_and_forecast_members_reject_before_string_name_casts() -> void:
	for value: Variant in [null,true,42,{},[],profile,"unknown_weather"]:
		payload.today = value
		_rejected(payload)
		payload.today = "sunny"
		payload.forecast[2] = value
		_rejected(payload)
		payload.forecast[2] = "sunny"

func test_wrong_forecast_containers_and_lengths_are_not_coerced() -> void:
	for value: Variant in [null,true,42,"sunny",{"0":"sunny"},PackedInt32Array([1,2,3]),[],["sunny"],["sunny","rain"],["sunny","rain","cloudy","storm"]]:
		payload.forecast = value
		_rejected(payload)

func test_packed_string_and_mixed_string_name_arrays_decode_to_detached_strings() -> void:
	for value: Variant in [PackedStringArray(["cloudy","rain","sunny"]),[&"cloudy","rain",&"sunny"]]:
		payload.forecast = value
		payload.today = &"sunny"
		var result: Dictionary = _decode()
		assert_true(bool(result.ok))
		assert_eq(result.snapshot.forecast,["cloudy","rain","sunny"])
		assert_true(result.snapshot.today is String)
		result.snapshot.forecast[0] = "storm"
		assert_eq(String(payload.forecast[0]),"cloudy")

func test_unknown_extra_keys_are_dropped_without_retaining_resource_references() -> void:
	payload.extra = profile
	payload.other = {"forecast":["storm"]}
	var before: String = var_to_str(payload)
	var result: Dictionary = _decode()
	assert_true(bool(result.ok))
	assert_eq(result.snapshot.size(),3)
	assert_false(result.snapshot.has("extra"))
	assert_false(result.snapshot.has("other"))
	assert_eq(var_to_str(payload),before)

func test_success_returns_fresh_arrays_and_never_changes_saved_choice_order() -> void:
	var first: Dictionary = _decode()
	first.snapshot.forecast.reverse()
	first.snapshot.forecast.append("storm")
	first.snapshot.today = "rain"
	assert_eq(payload.forecast,["cloudy","rain","sunny"])
	var second: Dictionary = _decode()
	assert_eq(second.snapshot,payload)
	assert_eq(SHIPPED.forecast_days,3)

func test_known_zero_weight_weather_remains_a_valid_saved_choice() -> void:
	profile.entries[2]["probability"] = 0
	var result: Dictionary = _decode()
	assert_true(bool(result.ok),"Saved rain is not rerolled when its weight becomes zero")
	assert_eq(result.snapshot.forecast,payload.forecast)
	profile.entries.remove_at(2)
	_rejected(payload)

func test_profile_owned_horizon_and_invalid_profiles_are_respected() -> void:
	profile.forecast_days = 1
	payload.forecast = ["sunny"]
	assert_true(bool(_decode().ok))
	profile.forecast_days = 0
	_rejected(payload)
	profile = SHIPPED.duplicate(true) as WeatherProfile
	profile.entries[0]["id"] = 42
	_rejected(payload)
	var missing: Dictionary = WeatherSnapshotCodec.decode(null,payload)
	assert_false(bool(missing.ok))
	assert_false(missing.has("snapshot"))

func test_decode_is_pure_repeated_and_emits_no_weather_events() -> void:
	var counts: Array[int] = [0,0]
	var weather_callback: Callable = func(_id: StringName) -> void: counts[0] += 1
	var forecast_callback: Callable = func(_forecast: Array[StringName]) -> void: counts[1] += 1
	Events.weather_changed.connect(weather_callback)
	Events.forecast_updated.connect(forecast_callback)
	var before: String = var_to_str(payload)
	var profile_before: String = var_to_str(profile.entries)
	var clock: Dictionary = GameClock.serialize()
	for _index: int in range(5):
		assert_eq(_decode().snapshot,payload)
	Events.weather_changed.disconnect(weather_callback)
	Events.forecast_updated.disconnect(forecast_callback)
	assert_eq(counts,[0,0])
	assert_eq(var_to_str(payload),before)
	assert_eq(var_to_str(profile.entries),profile_before)
	assert_eq(GameClock.serialize(),clock)
