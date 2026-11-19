extends GutTest

const SIM: Script = preload("res://tools/sim_director.gd")

func test_four_actual_profiles_keep_coverage_world_rng_and_clock_isolation() -> void:
	var clock: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	for style: String in SIM.STYLES:
		var result: Dictionary = SIM.run_scenario(14, 5, style, -42)
		assert_true(result.ok, str(result))
		if not result.ok: continue
		assert_eq(result.stats.days, 14)
		assert_eq(result.stats.duplicate_rejections, 14)
		assert_eq(result.unavailable, ["woodcutting", "fishing", "water_measurement", "story_unlock"])
		assert_eq(result.activity.completed_days.size(), 7)
		for row: Dictionary in result.activity.completed_days:
			assert_true(row.complete)
		if style == "inactive":
			assert_eq(result.stats.receipts, DirectorActivityCodec.empty_counts(SIM.ACTIVITY))
		else:
			assert_gt(result.stats.receipts.crop_planted, 0)
			assert_gt(result.stats.receipts.plot_watered, 0)
	assert_eq(GameClock.serialize(), clock)
	assert_eq(GameClock.paused, paused)

func test_grouping_does_not_change_decisions_and_decoded_continuations_are_exact() -> void:
	var first: Dictionary = SIM.run_scenario(35, 1, "balanced", 731)
	var grouped: Dictionary = SIM.run_scenario(35, 17, "balanced", 731)
	assert_true(first.ok, str(first))
	assert_true(grouped.ok, str(grouped))
	if not first.ok or not grouped.ok: return
	assert_eq(first.decision_sha256, grouped.decision_sha256)
	assert_eq(first.director, grouped.director)
	assert_eq(first.activity, grouped.activity)
	assert_eq(first.weather, grouped.weather)
	assert_eq(first.merchant, grouped.merchant)
	assert_eq(first.stats.roundtrips, 2)
	var segment: Dictionary = SIM.run_scenario(35, 17, "balanced", 731, {}, 28)
	assert_true(segment.ok and not segment.complete, str(segment.get("reason")))
	if not segment.ok: return
	assert_eq(segment.days, 28)
	var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(segment.checkpoint, "", true, true))
	var continued: Dictionary = SIM.run_scenario(35, 17, "balanced", 731, checkpoint, 28)
	assert_true(continued.ok and continued.complete, str(continued.get("reason")))
	if not continued.ok: return
	assert_eq(continued.decision_sha256, grouped.decision_sha256)
	assert_eq(continued.director, grouped.director)
	assert_eq(continued.weather, grouped.weather)
	assert_eq(continued.stats, grouped.stats)
	checkpoint.seed = -1
	assert_false(SIM.run_scenario(35, 17, "balanced", 731, checkpoint, 28).ok)
	assert_false(SIM.run_scenario(35, 17, "balanced", 731, {}, 27).ok)

func test_invalid_cli_scenarios_fail_without_clock_or_save_mutation() -> void:
	var clock: Dictionary = GameClock.serialize()
	for args: Array in [[0, 17, "balanced"], [1, 0, "balanced"], [1, 1, "woodcutting"], [1, 1, "fishing"]]:
		assert_false(SIM.run_scenario(args[0], args[1], args[2]).ok)
	assert_eq(GameClock.serialize(), clock)
