extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

static func snapshot(day: int = 7, seed: int = 0, tree: float = 29.0, diversity: float = 25.0, daily_activity: bool = false) -> Dictionary:
	var owner: DirectorActivityState = DirectorActivityState.new()
	owner.configure(DirectorSnapshot.ACTIVITY, day - DirectorSnapshot.ACTIVITY.window_days, true)
	for index: int in range(day - DirectorSnapshot.ACTIVITY.window_days, day):
		if daily_activity:
			for id: String in DirectorSnapshot.ACTIVITY.activity_ids:
				owner.record(index, StringName(id), 1)
		owner.advance_day(index + 1)
	var calendar: Dictionary = DirectorSnapshot.calendar(PROFILE, day)
	return DirectorSnapshot.capture(PROFILE, {"day_index": day, "minute": 360, "season": calendar.season_id, "year": calendar.year}, {"state": {"day_index": day, "metrics": {"tree_cover": tree, "biodiversity": diversity, "water_clarity": 100.0}, "triggered": []}, "available": {"tree_cover": true, "biodiversity": true, "water_clarity": false}}, owner.serialize(), {"day_index": day, "world_seed": seed, "today": "sunny", "forecast": ["sunny", "sunny", "sunny"]}, {"enabled": true, "story_unlocked": false, "debug_preview": true, "busy": false})

static func context(day: int = 7) -> Dictionary:
	var result: Dictionary = DirectorCandidateRules.fresh_context(0)
	result.last_positive_day = day
	return result

static func row(result: Dictionary, id: String) -> Dictionary:
	for candidate: Dictionary in result.candidates:
		if candidate.id == id:
			return candidate
	return {}

func test_base_scores_positive_affinity_bonus_and_no_event_weight_are_resource_owned() -> void:
	var basic: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(), context())
	assert_true(basic.ok)
	assert_eq(basic.total_weight, 4.0)
	assert_eq(basic.no_event_weight, 1.0)
	for candidate: Dictionary in basic.candidates:
		assert_true(candidate.eligible)
		assert_eq(candidate.score, 1.0)
	var diverse: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(7, 0, 29.0, 25.0, true), context())
	assert_eq(row(diverse, "merchant_visit").score, 1.5)
	assert_eq(row(diverse, "butterfly_bloom").score, 1.5)
	assert_eq(row(diverse, "gentle_dust").score, 1.0)
	assert_eq(diverse.total_weight, 5.0)

func test_negative_grace_spacing_and_target_season_pending_caps_are_enforced() -> void:
	var state: Dictionary = context()
	state.enabled_day = 7
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(), state), "gentle_dust").reason, "grace")
	state = context(10)
	state.last_negative_start = 10
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(10), state), "gentle_dust").reason, "negative_spacing")
	state = context(27)
	state.season_usage = {"28": 2}
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(27), state), "gentle_dust").reason, "negative_cap")
	state.season_usage = {"0": 2}
	assert_true(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(27), state), "gentle_dust").eligible, "Pending start29 belongs to the next actual season")
	state.scheduled = [{"event_id": "gentle_dust", "start_day": 28, "end_day": 29, "is_negative": true, "mutex_group": "weather_dust"}]
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(27), state), "gentle_dust").reason, "negative_spacing")

func test_cooldowns_mutex_and_per_event_cap_do_not_block_other_valid_positive_types() -> void:
	var state: Dictionary = context()
	state.cooldowns.gentle_dust = 10
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(), state), "gentle_dust").reason, "cooldown")
	state = context()
	state.scheduled = [{"event_id": "butterfly_bloom", "start_day": 7, "end_day": 9, "is_negative": false, "mutex_group": "butterfly"}]
	var result: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(), state)
	assert_eq(row(result, "butterfly_bloom").reason, "conflict")
	assert_true(row(result, "merchant_visit").eligible)
	state = context()
	state.event_usage = {"gentle_dust": {"0": 2}}
	assert_eq(row(DirectorCandidateRules.evaluate(PROFILE, snapshot(), state), "gentle_dust").reason, "event_cap")

func test_positive_pity_removes_lottery_none_and_waits_explicitly_when_positive_pool_empty() -> void:
	var state: Dictionary = DirectorCandidateRules.fresh_context(0)
	var result: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(), state)
	assert_true(result.pity)
	assert_eq(result.no_event_weight, 0.0)
	assert_eq(row(result, "gentle_dust").reason, "positive_pity")
	var waiting: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(9, 0, 29.0, 0.0), state)
	assert_true(waiting.pity_due)
	assert_false(waiting.pity)
	assert_eq(waiting.reason, "pity_waiting_eligible")
	var chosen: Dictionary = EventDirector.decide(PROFILE, snapshot(9, 0, 29.0, 0.0), state)
	assert_eq(chosen.event_id, "")
	assert_eq(chosen.reason, "pity_waiting_eligible")
	assert_null(chosen.seed_used)

func test_malformed_context_cannot_supply_fake_zero_cooldowns_or_quota() -> void:
	for mutation: Dictionary in [{"enabled_day": 8}, {"last_positive_day": 9}, {"season_usage": {"1": 0}}, {"season_usage": {"0": true}}, {"season_usage": {"0": 3}}, {"cooldowns": {"fake": 0}}, {"scheduled": [null]}, {"unknown": true}]:
		var state: Dictionary = context()
		state.merge(mutation, true)
		var result: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot(), state)
		assert_false(result.ok, str(mutation))
