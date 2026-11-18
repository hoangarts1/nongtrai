extends GutTest

const F: Script = preload("res://tests/unit/test_director_candidates.gd")
const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

func test_pinned_native_golden_preserves_tagged_choices_seeds_and_lossless_rng_text() -> void:
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/director_rng_v0.json"))
	assert_eq(golden.engine, Engine.get_version_info().string)
	for vector: Dictionary in golden.vectors:
		var snapshot: Dictionary = F.snapshot(int(vector.day), int(vector.world_seed))
		var decision: Dictionary = EventDirector.decide(PROFILE, snapshot, F.context(int(vector.day)))
		assert_true(decision.ok)
		assert_eq(decision.event_id, vector.event_id)
		assert_eq(int(decision.seed_used), int(vector.seed_used))
		assert_eq(decision.rng_state, vector.rng_state)
		assert_eq(str(String(decision.rng_state).to_int()), String(decision.rng_state))

func test_repeated_choice_is_identical_and_does_not_consume_weather_or_merchant_streams() -> void:
	var snapshot: Dictionary = F.snapshot()
	var context: Dictionary = F.context()
	var before: Dictionary = snapshot.duplicate(true)
	var state: Dictionary = context.duplicate(true)
	var choice: Dictionary = EventDirector.decide(PROFILE, snapshot, context)
	for _index: int in range(30):
		assert_eq(EventDirector.decide(PROFILE, snapshot, context), choice)
	assert_eq(snapshot, before)
	assert_eq(context, state)
	assert_eq(DetRandom.TAG_WEATHER, 1)
	assert_eq(DetRandom.TAG_MERCHANT, 8)
	assert_eq(DetRandom.TAG_DIRECTOR, 2)
	for tag: int in [DetRandom.TAG_WEATHER, DetRandom.TAG_MERCHANT]:
		var first: RandomNumberGenerator = DetRandom.make_rng(-42, 7, tag)
		var second: RandomNumberGenerator = DetRandom.make_rng(-42, 7, tag)
		var expected: int = second.randi()
		EventDirector.decide(PROFILE, F.snapshot(7, -42), context)
		assert_eq(first.randi(), expected)

func test_forced_choice_keeps_forewarning_and_constraints_without_a_lottery_draw() -> void:
	var forced: Dictionary = EventDirector.decide(PROFILE, F.snapshot(), F.context(), &"gentle_dust")
	assert_true(forced.ok)
	assert_eq(forced.event_id, "gentle_dust")
	assert_eq(forced.reason, "forced")
	assert_eq(forced.event.start_day, 9)
	assert_eq(forced.event.end_day, 10)
	assert_eq(forced.event.effect.extra_charge, 1)
	assert_true(forced.trace.forced)
	assert_false(EventDirector.decide(PROFILE, F.snapshot(7, 0, 30.0), F.context(), &"gentle_dust").ok)
	assert_false(EventDirector.decide(PROFILE, F.snapshot(), F.context(), &"fake").ok)
