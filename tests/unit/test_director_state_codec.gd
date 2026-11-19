extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const STATES: Script = preload("res://tests/unit/test_director_state.gd")

func test_wire_rejects_missing_extra_bool_fraction_and_malformed_schedule_atomically() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	owner.queue_force(&"butterfly_bloom", true)
	assert_true(STATES.step(owner, 7).ok)
	var before: Dictionary = owner.serialize()
	for key: String in before:
		var missing: Dictionary = before.duplicate(true)
		missing.erase(key)
		assert_false(owner.deserialize(missing), key)
		assert_eq(owner.serialize(), before)
	for value: Variant in [true, -1, 7.25, INF, NAN, "7", null]:
		var bad: Dictionary = before.duplicate(true)
		bad.day_index = value
		assert_false(owner.deserialize(bad))
		assert_eq(owner.serialize(), before)
	for value: Variant in [null, {}, [null], [true], [{"event_id": "unknown"}]]:
		var bad: Dictionary = before.duplicate(true)
		bad.active = value
		assert_false(owner.deserialize(bad))
		assert_eq(owner.serialize(), before)
	var extra: Dictionary = before.duplicate(true)
	extra.unknown = true
	assert_false(owner.deserialize(extra))

func test_rng_text_history_order_quota_and_captured_terms_cannot_be_corrupted() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	owner.queue_force(&"butterfly_bloom", true)
	assert_true(STATES.step(owner, 7).ok)
	var before: Dictionary = owner.serialize()
	for text: String in ["01", "+1", "9223372036854775808", "-9223372036854775809", "1.0", ""]:
		var bad: Dictionary = before.duplicate(true)
		bad.history[0].rng_state = text
		assert_false(owner.deserialize(bad), text)
	var bad: Dictionary = before.duplicate(true)
	bad.active[0].effect.accent[0] = 5.0
	assert_false(owner.deserialize(bad))
	bad = before.duplicate(true)
	bad.history[0].day_index = 6
	assert_false(owner.deserialize(bad))
	bad = before.duplicate(true)
	bad.event_usage = {}
	assert_false(owner.deserialize(bad))
	bad = before.duplicate(true)
	bad.enabled = false
	assert_false(owner.deserialize(bad))
	assert_eq(owner.serialize(), before)

func test_pruning_history_keeps_actual_cooldowns_quota_pity_and_lossless_rng() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	for day: int in range(7, 147):
		assert_true(STATES.step(owner, day).ok, str(day))
	var raw: Dictionary = owner.serialize()
	assert_eq(raw.history.size(), PROFILE.history_limit)
	assert_eq(int(raw.history[0].day_index), 19)
	assert_eq(int(raw.history.back().day_index), 146)
	assert_false(raw.cooldowns.is_empty())
	assert_not_null(raw.last_positive_day)
	var restored: DirectorState = DirectorState.new()
	restored.configure(PROFILE, 0)
	assert_true(restored.deserialize(JSON.parse_string(JSON.stringify(raw, "", true, true))))
	assert_eq(restored.serialize(), raw)
	assert_eq(STATES.step(restored, 147), STATES.step(owner, 147))

func test_forged_adjacent_negative_starts_are_rejected_even_with_booked_quota() -> void:
	var raw: Dictionary = DirectorSnapshotCodec.baseline(0)
	raw.enabled = true
	raw.day_index = 10
	for day: int in range(1, 11):
		var decision: Dictionary = DirectorHistoryRules.empty_decision(day)
		if day in [7, 8]:
			decision.reason = "forced"
			decision.seed_used = 1
			decision.rng_state = "1"
			decision.event_id = "gentle_dust"
			decision.event = EventDirector.event_terms(PROFILE.get_event(&"gentle_dust"), day)
		raw.history.append(decision)
	raw.active = [raw.history[7].event.duplicate(true)]
	raw.last_negative_start = 10
	raw.cooldowns = {"gentle_dust": 17}
	raw.season_usage = {"0": 2}
	raw.event_usage = {"gentle_dust": {"0": 2}}
	assert_false(DirectorSnapshotCodec.decode(PROFILE, raw).ok)
