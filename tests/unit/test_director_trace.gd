extends GutTest

const F: Script = preload("res://tests/unit/test_director_candidates.gd")
const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

func test_every_candidate_has_actual_score_or_exclusion_details_and_detached_trace() -> void:
	var snapshot: Dictionary = F.snapshot(9, -1, 30.0, 24.0)
	var before: Dictionary = snapshot.duplicate(true)
	var decision: Dictionary = EventDirector.decide(PROFILE, snapshot, F.context(9))
	assert_true(decision.ok)
	assert_eq(decision.trace.candidates.size(), 3)
	assert_eq(F.row(decision.trace, "gentle_dust").reason, "threshold")
	assert_eq(F.row(decision.trace, "merchant_visit").reason, "regular_visit")
	assert_eq(F.row(decision.trace, "butterfly_bloom").reason, "threshold")
	assert_eq(decision.event_id, "")
	assert_null(decision.seed_used)
	decision.trace.candidates[0].reason = "invented"
	assert_eq(snapshot, before)

func test_disabled_locked_partial_and_invalid_inputs_never_roll_or_invent_candidates() -> void:
	var snapshot: Dictionary = F.snapshot()
	snapshot.source.gates.enabled = false
	var s: Dictionary = snapshot.source
	snapshot = DirectorSnapshot.capture(PROFILE, s.clock, s.ecology, s.activity, s.weather, s.gates)
	var result: Dictionary = EventDirector.decide(PROFILE, snapshot, {})
	assert_true(result.ok)
	assert_eq(result.reason, "disabled")
	assert_null(result.seed_used)
	assert_eq(result.rng_state, "")
	assert_eq(result.trace.candidates.size(), 3)
	for row: Dictionary in result.trace.candidates:
		assert_false(row.eligible)
		assert_eq(row.score, 0.0)
		assert_eq(row.reason, "disabled")
	snapshot.metrics.tree_cover = NAN
	assert_false(EventDirector.decide(PROFILE, snapshot, F.context()).ok)
