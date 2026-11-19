extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const OBS: Script = preload("res://tests/unit/test_director_candidates.gd")

static func step(owner: DirectorState, day: int, observation: Dictionary = {}) -> Dictionary:
	var reserved: Dictionary = owner.begin_day(day)
	if not reserved.ok:
		return reserved
	return owner.finish_day(reserved.token, OBS.snapshot(day) if observation.is_empty() and owner.is_enabled() else observation)

static func enabled_owner(day: int = 6) -> DirectorState:
	var result: DirectorState = DirectorState.new()
	result.configure(PROFILE, day)
	result.set_enabled(true, true)
	return result

func test_default_off_has_no_rng_no_fake_history_and_requires_explicit_authorization() -> void:
	var owner: DirectorState = DirectorState.new()
	assert_true(owner.configure(PROFILE, 41))
	assert_false(owner.is_enabled())
	assert_eq(owner.serialize().history, [])
	assert_false(owner.set_enabled(true))
	assert_false(owner.queue_force(&"gentle_dust", true))
	assert_true(step(owner, 42).ok)
	var decision: Dictionary = owner.serialize().history[0]
	assert_eq(decision.reason, "disabled")
	assert_null(decision.seed_used)
	assert_eq(decision.rng_state, "")
	assert_true(owner.set_enabled(true, true))
	assert_eq(int(owner.serialize().enabled_day), 42)

func test_forced_negative_keeps_telegraph_activation_expiry_and_target_season_usage() -> void:
	var owner: DirectorState = enabled_owner(6)
	for day: int in range(7, 26):
		assert_true(step(owner, day, OBS.snapshot(day, 0, 30.0, 0.0)).ok)
	assert_true(owner.queue_force(&"butterfly_bloom", true))
	assert_true(step(owner, 26).ok)
	assert_true(owner.queue_force(&"gentle_dust", true))
	var result: Dictionary = step(owner, 27)
	assert_true(result.ok)
	assert_eq(result.decision.event_id, "gentle_dust")
	assert_eq(int(result.decision.event.start_day), 29)
	assert_eq(int(result.decision.event.end_day), 30)
	assert_eq(int(owner.serialize().season_usage["28"]), 1)
	assert_eq(owner.serialize().pending.size(), 1)
	assert_true(step(owner, 28).ok)
	assert_true(step(owner, 29).ok)
	assert_eq(owner.serialize().pending.size(), 0)
	var found: bool = false
	for event: Dictionary in owner.serialize().active:
		found = found or event.event_id == "gentle_dust"
	assert_true(found)
	assert_eq(int(owner.serialize().last_negative_start), 29)
	assert_true(step(owner, 30).ok)
	for event: Dictionary in owner.serialize().active:
		assert_ne(event.event_id, "gentle_dust")

func test_force_decline_consumes_once_without_random_fallback_and_disable_clears_application() -> void:
	var owner: DirectorState = enabled_owner()
	assert_true(owner.queue_force(&"gentle_dust", true))
	var declined: Dictionary = step(owner, 7)
	assert_true(declined.ok)
	assert_eq(declined.decision.reason, "forced_ineligible", "Grace still applies")
	assert_eq(declined.decision.event_id, "")
	assert_null(declined.decision.seed_used)
	assert_eq(owner.serialize().forced, "")
	assert_true(owner.queue_force(&"butterfly_bloom", true))
	assert_true(step(owner, 8).ok)
	assert_eq(owner.serialize().active.size(), 1)
	var history: Array = owner.serialize().history
	assert_true(owner.set_enabled(false))
	assert_eq(owner.serialize().active, [])
	assert_eq(owner.serialize().pending, [])
	assert_eq(owner.serialize().history, history, "Past decisions remain immutable")
	assert_true(owner.set_enabled(true, true))
	assert_eq(int(owner.serialize().enabled_day), 8)
	assert_null(owner.serialize().last_positive_day)

func test_detached_snapshots_and_silent_exact_restore_do_not_reroll_or_replay() -> void:
	var owner: DirectorState = enabled_owner()
	owner.queue_force(&"butterfly_bloom", true)
	assert_true(step(owner, 7).ok)
	var raw: Dictionary = owner.serialize()
	var restored: DirectorState = DirectorState.new()
	restored.configure(PROFILE, 99)
	watch_signals(restored)
	assert_true(restored.deserialize(JSON.parse_string(JSON.stringify(raw, "", true, true))))
	assert_signal_not_emitted(restored, "director_changed")
	assert_eq(restored.serialize(), raw)
	var detached: Dictionary = restored.serialize()
	detached.active[0].effect.extra_charge = 999
	detached.history.clear()
	assert_eq(restored.serialize(), raw)
	assert_eq(step(restored, 8), step(owner, 8))

func test_new_season_booking_preserves_prior_season_event_until_its_actual_expiry() -> void:
	var owner: DirectorState = enabled_owner(26)
	assert_true(owner.queue_force(&"butterfly_bloom", true))
	assert_true(step(owner, 27).ok)
	assert_true(owner.queue_force(&"merchant_visit", true))
	assert_true(step(owner, 28).ok)
	var raw: Dictionary = owner.serialize()
	assert_eq(raw.active.size(), 2)
	assert_eq(int(raw.event_usage.butterfly_bloom["0"]), 1)
	assert_eq(int(raw.event_usage.merchant_visit["28"]), 1)
	assert_true(DirectorSnapshotCodec.decode(PROFILE, raw).ok)
	assert_true(step(owner, 29).ok)
	assert_eq(owner.serialize().active.size(), 0)
