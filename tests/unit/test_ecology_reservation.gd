extends GutTest

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
var _state: EcologyState

func before_each() -> void:
	_state = EcologyState.new()
	assert_true(_state.configure(PROFILE))

func _targets(value: float) -> Dictionary:
	return {"tree_cover": value, "water_clarity": value, "biodiversity": value}

func test_quote_is_read_only_and_only_accepts_adjacent_configured_day() -> void:
	assert_false(EcologyState.new().day_quote(1).ok)
	var before: Dictionary = _state.serialize()
	for day: int in [-1, 0, 2, 9007199254740991]:
		assert_false(_state.day_quote(day).ok)
	assert_true(_state.day_quote(1).ok)
	assert_eq(_state.serialize(), before)
	assert_false(_state.is_busy())

func test_reservation_blocks_mutations_and_keeps_committed_reads_until_abort() -> void:
	var before: Dictionary = _state.serialize()
	var reservation: Dictionary = _state.begin_day(1)
	assert_true(reservation.ok)
	assert_true(_state.is_busy())
	assert_false(_state.configure(PROFILE))
	assert_false(_state.deserialize(before))
	assert_false(_state.advance_day(1, _targets(100.0)).ok)
	assert_false(_state.begin_day(1).ok)
	assert_false(_state.day_quote(1).ok)
	assert_false(_state.finish_day(int(reservation.token) + 1, _targets(100.0)).ok)
	assert_false(_state.abort_day(int(reservation.token) + 1))
	assert_eq(_state.serialize(), before)
	assert_true(_state.abort_day(reservation.token))
	assert_false(_state.is_busy())
	assert_eq(_state.serialize(), before)

func test_invalid_targets_retain_reservation_and_retry_commits_once() -> void:
	var reservation: Dictionary = _state.begin_day(1)
	watch_signals(_state)
	assert_false(_state.finish_day(reservation.token, {}).ok)
	assert_true(_state.is_busy())
	assert_eq(_state.get_day_index(), 0)
	assert_signal_not_emitted(_state, "ecology_changed")
	assert_true(_state.finish_day(reservation.token, _targets(100.0)).ok)
	assert_eq(_state.get_metrics(), _targets(10.0))
	assert_eq(_state.get_day_index(), 1)
	assert_signal_emit_count(_state, "ecology_changed", 1)
	assert_false(_state.finish_day(reservation.token, _targets(100.0)).ok)
	assert_false(_state.abort_day(reservation.token))

func test_tokens_do_not_recur_after_abort_reconfigure_or_silent_load() -> void:
	var first: Dictionary = _state.begin_day(1)
	assert_true(_state.abort_day(first.token))
	assert_true(_state.configure(PROFILE, 10))
	var saved: Dictionary = _state.serialize()
	assert_true(_state.deserialize(saved))
	var second: Dictionary = _state.begin_day(11)
	assert_gt(int(second.token), int(first.token))
	assert_false(_state.finish_day(first.token, _targets(100.0)).ok)
	assert_false(_state.abort_day(first.token))
	assert_true(_state.finish_day(second.token, _targets(100.0)).ok)
	assert_eq(_state.get_day_index(), 11)

func test_publication_keeps_guard_and_readers_see_committed_day() -> void:
	var reservation: Dictionary = _state.begin_day(1)
	var calls: Array[int] = [0]
	_state.ecology_changed.connect(func(_metrics: Dictionary) -> void:
		calls[0] += 1
		assert_eq(_state.get_day_index(), 1)
		assert_eq(_state.get_metrics(), _targets(10.0))
		assert_true(_state.is_busy())
		assert_false(_state.abort_day(reservation.token))
		assert_false(_state.finish_day(reservation.token, _targets(0.0)).ok)
		assert_false(_state.configure(PROFILE))
		assert_false(_state.deserialize(_state.serialize()))
		assert_false(_state.advance_day(2, _targets(0.0)).ok)
	)
	assert_true(_state.finish_day(reservation.token, _targets(100.0)).ok)
	assert_eq(calls[0], 1)
	assert_false(_state.is_busy())

func test_reservation_is_never_serialized_or_replayed_by_load() -> void:
	var before: Dictionary = _state.serialize()
	var reservation: Dictionary = _state.begin_day(1)
	assert_eq(_state.serialize(), before)
	var restored: EcologyState = EcologyState.new()
	assert_true(restored.configure(PROFILE))
	assert_true(restored.deserialize(JSON.parse_string(JSON.stringify(_state.serialize(), "", true, true))))
	assert_false(restored.is_busy())
	assert_eq(restored.serialize(), before)
	assert_false(restored.finish_day(reservation.token, _targets(100.0)).ok)
	assert_true(_state.abort_day(reservation.token))

func test_reserved_easing_and_crossings_match_existing_advance_path() -> void:
	var direct: EcologyState = EcologyState.new()
	assert_true(direct.configure(PROFILE))
	for day: int in range(1, 40):
		var targets: Dictionary = _targets(100.0 if day < 15 else 0.0)
		var reservation: Dictionary = _state.begin_day(day)
		assert_true(reservation.ok)
		assert_true(_state.finish_day(reservation.token, targets).ok)
		assert_true(direct.advance_day(day, targets).ok)
		assert_eq(_state.serialize(), direct.serialize())

func test_native_json_preserves_threshold_sides_and_owner_keeps_exact_decoded_values() -> void:
	watch_signals(_state)
	for threshold: Dictionary in PROFILE.get_thresholds():
		for offset: int in [-1, 0, 1]:
			var bytes: PackedByteArray = PackedByteArray()
			bytes.resize(8)
			bytes.encode_double(0, float(threshold.value))
			var bits: int = bytes.decode_s64(0)
			bytes.encode_s64(0, bits + offset)
			var value: float = bytes.decode_double(0)
			var metrics: Dictionary = _targets(0.0)
			metrics[threshold.metric_id] = value
			var raw: Dictionary = {"day_index": 0, "metrics": metrics, "triggered": []}
			var parsed: Dictionary = JSON.parse_string(JSON.stringify(raw, "", true, true))
			assert_true(_state.deserialize(parsed))
			assert_eq(_state.get_metrics()[threshold.metric_id], float(parsed.metrics[threshold.metric_id]))
			assert_eq(_state.is_threshold_active(StringName(threshold.id)), value >= float(threshold.value))
			assert_eq(_state.get_triggered(), PackedStringArray())
	assert_signal_not_emitted(_state, "ecology_changed")
	assert_signal_not_emitted(_state, "threshold_crossed")
