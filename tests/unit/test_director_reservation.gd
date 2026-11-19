extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const OBS: Script = preload("res://tests/unit/test_director_candidates.gd")
const STATES: Script = preload("res://tests/unit/test_director_state.gd")

func test_exact_next_token_rejects_duplicate_skip_stale_and_invalid_without_mutation() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	var before: Dictionary = owner.serialize()
	assert_false(owner.begin_day(6).ok)
	assert_false(owner.begin_day(8).ok)
	var reservation: Dictionary = owner.begin_day(7)
	assert_true(reservation.ok)
	assert_true(owner.is_busy())
	assert_false(owner.begin_day(7).ok)
	assert_false(owner.configure(PROFILE, 0))
	assert_false(owner.set_enabled(false))
	assert_false(owner.queue_force(&"butterfly_bloom", true))
	assert_false(owner.deserialize(before))
	assert_false(owner.finish_day(RefCounted.new(), OBS.snapshot()).ok)
	assert_false(owner.abort_day(RefCounted.new()))
	assert_false(owner.finish_day(reservation.token, {}).ok)
	assert_eq(owner.serialize(), before)
	assert_true(owner.finish_day(reservation.token, OBS.snapshot()).ok)
	assert_false(owner.finish_day(reservation.token, OBS.snapshot()).ok)
	assert_false(owner.abort_day(reservation.token))
	assert_false(owner.begin_day(7).ok)

func test_notification_guards_all_mutation_paths_and_valid_abort_preserves_snapshot() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	var before: Dictionary = owner.serialize()
	var token: RefCounted = owner.begin_day(7).token
	assert_true(owner.abort_day(token))
	assert_eq(owner.serialize(), before)
	var probes: Array[bool] = []
	var handler: Callable = func(day: int) -> void:
		probes.append(owner.is_busy())
		probes.append(not owner.set_enabled(false))
		probes.append(not owner.queue_force(&"butterfly_bloom", true))
		probes.append(not owner.configure(PROFILE, day))
		probes.append(not owner.deserialize(before))
		probes.append(not owner.begin_day(day + 1).ok)
		probes.append(not owner.abort_day(token))
	owner.director_changed.connect(handler)
	assert_true(STATES.step(owner, 7).ok)
	assert_eq(probes.size(), 7)
	for probe: bool in probes:
		assert_true(probe)
	assert_false(owner.is_busy())
	owner.director_changed.disconnect(handler)

func test_invalid_candidate_preserves_reservation_and_can_retry_with_valid_observation() -> void:
	var owner: DirectorState = STATES.enabled_owner()
	var before: Dictionary = owner.serialize()
	var token: RefCounted = owner.begin_day(7).token
	var invalid: Dictionary = OBS.snapshot()
	invalid.metrics.tree_cover = 999
	assert_false(owner.finish_day(token, invalid).ok)
	assert_true(owner.is_busy())
	assert_eq(owner.serialize(), before)
	assert_true(owner.finish_day(token, OBS.snapshot()).ok)
	assert_eq(owner.get_day_index(), 7)
