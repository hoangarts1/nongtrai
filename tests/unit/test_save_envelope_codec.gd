extends GutTest

func test_every_historical_golden_is_accepted_with_original_fields() -> void:
	for version: int in range(1, SaveService.CURRENT_VERSION + 1):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		assert_true(raw is Dictionary, path)
		var before: Dictionary = raw.duplicate(true)
		var result: Dictionary = SaveEnvelopeCodec.decode(raw, SaveService.CURRENT_VERSION)
		assert_true(result.ok, path)
		assert_eq(result.version, version, path)
		assert_eq(result.data, before, path)
		assert_eq(raw, before, "Codec must not migrate/repair the payload")

func test_legacy_zero_and_integral_json_floats_remain_compatible() -> void:
	for raw: Dictionary in [{}, {"clock": {"day_index": 1}}, {"meta": {}}, {"meta": {"save_version": 0.0}}]:
		var result: Dictionary = SaveEnvelopeCodec.decode(raw, SaveService.CURRENT_VERSION)
		assert_true(result.ok)
		assert_eq(result.version, 0)
		assert_eq(result.data, raw)
	var parsed: Variant = JSON.parse_string('{"meta":{"save_version":12.0},"unknown":[1,2]}')
	var current: Dictionary = SaveEnvelopeCodec.decode(parsed, SaveService.CURRENT_VERSION)
	assert_true(current.ok)
	assert_eq(current.version, 12)
	assert_eq(current.data, parsed)

func test_invalid_root_metadata_and_versions_fail_without_coercion() -> void:
	for raw: Variant in [null, [], PackedStringArray(), "{}", true, 12, 12.0]:
		var result: Dictionary = SaveEnvelopeCodec.decode(raw, SaveService.CURRENT_VERSION)
		assert_false(result.ok)
		assert_eq(result.error, &"invalid_root")
		assert_eq(result.data, {})
	for metadata: Variant in [null, [], "meta", true, 12]:
		var result: Dictionary = SaveEnvelopeCodec.decode({"meta": metadata}, SaveService.CURRENT_VERSION)
		assert_false(result.ok)
		assert_eq(result.error, &"invalid_meta")
	for value: Variant in [null, true, false, "12", [], {}, -1, -0.5, 0.5, 11.99, 12.01, NAN, INF, -INF, 1.0e100, 9223372036854775807]:
		var result: Dictionary = SaveEnvelopeCodec.decode({"meta": {"save_version": value}}, SaveService.CURRENT_VERSION)
		assert_false(result.ok, str(value))
		assert_eq(result.error, &"invalid_version", str(value))
		assert_eq(result.version, -1)
		assert_eq(result.data, {})

func test_future_version_is_distinct_and_current_version_is_an_explicit_boundary() -> void:
	for value: Variant in [13, 13.0, SaveEnvelopeCodec.MAX_JSON_INTEGER]:
		var result: Dictionary = SaveEnvelopeCodec.decode({"meta": {"save_version": value}}, 12)
		assert_false(result.ok)
		assert_eq(result.error, &"unsupported_future")
		assert_eq(result.version, int(value))
		assert_eq(result.data, {})
	assert_true(SaveEnvelopeCodec.decode({"meta": {"save_version": 13}}, 13).ok)
	for limit: int in [-1, 9223372036854775807]:
		assert_eq(SaveEnvelopeCodec.decode({}, limit).error, &"invalid_current_version")

func test_nested_unknown_components_are_preserved_and_detached_both_directions() -> void:
	var raw: Dictionary = {"meta": {"save_version": 12, "extra": ["kept"]}, "unknown": {"values": [{"n": 4}]}}
	var before: Dictionary = raw.duplicate(true)
	var result: Dictionary = SaveEnvelopeCodec.decode(raw, 12)
	result.data.unknown.values[0].n = 99
	result.data.meta.extra.append("changed")
	assert_eq(raw, before)
	raw.unknown.values.append({"n": 5})
	assert_eq(result.data.unknown.values.size(), 1)
	assert_eq(result.data.meta.save_version, 12)
